#version 430
#extension GL_ARB_explicit_attrib_location : enable

in vec2 texcoord;

#include "/lib/Settings.glsl"

uniform usampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D colortex1;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex13;
uniform sampler2D colortex8;
uniform sampler2D colortex7;
uniform sampler2D colortex9;
uniform sampler2D colortex2;
uniform usampler2D colortex3;
uniform vec3 sunPosition;
uniform vec3 sunVector;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform usampler2D shadowcolor1;
uniform sampler2D depthtex2;
uniform float far;
uniform int frameCounter;
uniform vec2 resolution;
uniform int hideGUI;
uniform vec2 pixelSize;

#include "/lib/Random.glsl"
#include "/lib/Projection.glsl"
#include "/lib/Encoding.glsl"
#include "/lib/SSRT.glsl"
#include "/lib/Voxelization.glsl"
#include "/lib/Voxel_Intersect.glsl"
#include "/lib/BRDF.glsl"
#include "/lib/Atmosphere.glsl"

const vec3 sun = (vec3(6000.) * (vec3(1.0, 0.89, 0.85) * sRGBtoAP1));
const vec3 sky = vec3(47.*100.);
const vec3 sunTransmittance = getValFromTLUT(colortex13, resolution, vec3(0.0, groundRadiusMM + 0.000063, 0.0), sunVector);



void calculateIrradiance(material mat, float depth, float accumulation, out reservoir reservoirData, out bool isSpecularBounce, out float reflectedHitDist, out vec3 diffuse, out vec3 specular) {

	const int range = 50; //int(far * sqrt(3));
	const float boundary = 127.0;

	vec3 screen   = vec3(texcoord / TAAUres, depth);

	vec3 viewPos = screenToView(screen);

	vec3 feet = screenToFeet(screen);

    vec3 t;
    vec3 L;
    vec3 N = (mat3(gbufferModelViewInverse) * mat.normal);
	vec3 V = mat3(gbufferModelViewInverse) *  normalize(viewPos);

	vec4[2] voxel;
    vec3 hitPos, hitNormal;
    vec3 accColor;
    float pdf;
	vec3 origin = SceneSpaceToVoxelSpace( feet ) + (N)*0.05;


	material hitMat;

	bool inBoundary = (clamp(feet, vec3(-boundary), vec3(boundary)) == feet); 
	bool doDiffuse = true;

	#ifdef RoughSpecular
	//mat.roughness = pow(mat.roughness, 1.3);
		float roughnessThreshold = 0.75;
	#else
		float roughnessThreshold = 0.1;
	#endif

	


	vec3 H = getDirectionGGXVNDF((N),  V,  mat.roughness, vec2(randF(), randF()));

	float NdotV = clamp(dot(N, -V), EPS, 1.0);

	vec3 fresnel = fresnelSchlick(clamp01(dot(-V, H)), mix(vec3(mat.f0), mat.albedo, mat.isMetal));



    float specP = luma(fresnel) * float(mat.roughness <= roughnessThreshold) ;
/*
    //if (specP==0.) return;
    float diffP = max0(1.0-float(mat.isMetal));
    float invP = 1./(diffP + specP);
    	  //diffP *= invP;
    	  //specP *= invP;
*/

	for(int i = 0; i < SpecularSamples; ++i) {

			//specular, the smooth one
		L = reflect(V, H);

			//if((dot(L, (N)) <= 0.0) || (dir!=dir)) continue;
		float NdotL = clamp(dot(N, L), 0.0, 1.0);
		if(specP > EPS && !(NdotL == 0.0) || (L!=L)) {

			vec3 dir = L;


			pdf = max(G1Smith(NdotV, mat.roughness), EPS);

			t =  fresnel * G2Smith(NdotL, NdotV, mat.roughness) / max(EPS, pdf);

			if(inBoundary){
			    bool hit = RaytraceVoxel(origin, ivec3(floor(origin)),  dir, false, range, voxel, hitPos, hitNormal, accColor);
			    
			    if(hit) {

				    getMaterial(hitMat, hitPos, hitNormal, voxel);

				    #ifdef IrradianceCaching
				   	
						vec3 cache = texelFetch(colortex2, GetVoxelStoragePos(ivec3(floor(hitPos+randomHemisphereVector(hitMat.normal)*max(0.3,randF())))), 0).rgb ;
					#else
						vec3 cache = vec3(0.0);

					#endif

					float dist = 1.;

					vec3 feetHitPos = VoxelSpaceToSceneSpace(hitPos);

					vec3 screenHitPos = feetToScreen(feetHitPos);

					bool screenHit = (clamp(screenHitPos.xy, vec2(0.0), vec2(1.0)) == screenHitPos.xy && screenHitPos.z < texture(depthtex0, screenHitPos.xy).r + 1.e-4);

					vec3 sunLight = (calculateShadow(shadowtex1, feetToShadowScreen(feetHitPos+hitMat.normal*EPS ), 0.0003)  * sun * sunTransmittance) * max0(dot(hitMat.normal, normalize(sunPosition)));


					specular += screenHit ? pow(texture(colortex4, toPrevScreenPos(screenHitPos.xy, screenHitPos.z)).rgb, vec3(1.0)) * t * accColor : (hitMat.albedo * ((hitMat.emission + sunLight) + cache * min(dist, 1.)))  * t * accColor;
				    


				} else {

				   		specular += t *getValFromSkyLUT(normalize(dir),  sunVector)*sky * accColor;
				   		hitPos = origin;
				   		
				   		
				}
			} else {
				   	specular += t *getValFromSkyLUT(normalize(dir),  sunVector)*sky;
				   	hitPos = origin;
				   	
			}


		}


		//vec3 p = screenToView(vec3(texcoord, depth));
		//float viewVectorLength = length(p);
		reflectedHitDist += distance(origin, ((hitPos)));

		//reflectedPos = viewToScreen(normalize(p) * (viewVectorLength + reflectedVectorLength * clamp01(f)) );
		H = getDirectionGGXVNDF((N),  V,  mat.roughness, vec2(randF(), randF()));



		fresnel = fresnelSchlick(clamp01(dot(-V, H)), mix(vec3(mat.f0), mat.albedo, mat.isMetal));

	}


	for(int i = 0; i < DiffuseSamples + 1 - accumulation && !mat.isMetal; ++i) { //diffuse

		#ifdef CosineSampling
			L = cosineWeightedHemisphereSample((N), vec2(randF(), randF()));
			pdf = 1.;
		#else
			L = uniformHemisphereSample((N), vec2(randF(), randF()));
			pdf = ((1.0/TAU) / max(EPS, dot(N, L)));
		#endif
	
		//if(dot(L, getGeometryNormal(N)) <= 0.0) continue;

		t 	= vec3(invPI) * (1.0-fresnel) * vec3(float(!mat.isMetal) / max(EPS, pdf ));

	

	vec3 dir =  L;
	//diffuse, but actually also contains rough specular
		vec3 diffuseOrigin = origin;

	for(int j = 0; j < RayBounce ; j++ ){
		//diffuse += texelFetch(shadowcolor0, GetVoxelStoragePos(ivec3(floor(origin+randomHemisphereVector(N)*0.5))), 0).rgb * mat.albedo;continue;
		if(inBoundary){
	    bool hit = RaytraceVoxel(diffuseOrigin, ivec3(floor(diffuseOrigin)),  dir, false, range-(j*2), voxel, hitPos, hitNormal, accColor);
	    
	    if(hit) {

		    getMaterial(hitMat, hitPos, hitNormal, voxel);


		    #ifdef IrradianceCaching
		   	
				vec3 cache = texelFetch(colortex2, GetVoxelStoragePos(ivec3(floor(hitPos+randomHemisphereVector(hitNormal)*0.5))), 0).rgb  ;
			#else
				vec3 cache = vec3(0.0);

			#endif

			vec3 feetHitPos = VoxelSpaceToSceneSpace(hitPos);

			//vec3 screenHitPos = feetToScreen(feetHitPos);

			//bool screenHit = (clamp(screenHitPos.xy, vec2(0.0), vec2(1.0)) == screenHitPos.xy && screenHitPos.z < texture(depthtex0, screenHitPos.xy).r + 1.e-4);

			vec3 sunLight = (calculateShadow(shadowtex1, feetToShadowScreen(feetHitPos+hitMat.normal*EPS ), 0.0003)  * sun * sunTransmittance) * max0(dot(hitMat.normal, normalize(sunPosition)));
			
			float dist = distance(hitPos, diffuseOrigin);
				  //dist = sqrt(max(dist  , EPS));//((hitMat.emission > EPS || length(sunLight) > EPS)) ? 1.0 : 
//+(screenHit?texture(colortex1, toPrevScreenPos(screenHitPos.xy, screenHitPos.z)*TAAUres).rgb:vec3(0.0))
			diffuse += ( (hitMat.albedo * ((hitMat.emission+sunLight)/max(1.0, pow2(dist*0.3)) + (cache* mix(pow2(min(dist*0.5 , 1.0)), 1.0, float((hitMat.emission > EPS || length(sunLight) > EPS))) ))) ) * t * accColor;

			if(hitMat.emission > EPS) break;

			diffuseOrigin = hitPos + hitNormal * 1.e-4;

			#ifdef CosineSampling

				dir = cosineWeightedHemisphereSample((hitNormal), vec2(randF(), randF()));

				t *= (hitMat.albedo/PI) * float(!hitMat.isMetal);

			#else 

				dir = uniformHemisphereSample(hitNormal, vec2(randF(), randF()));

				t *= (hitMat.albedo) * float(!hitMat.isMetal) * max0(dot(dir, hitNormal)) * 2.;

			#endif

			//float p = maxof(t);if(randF() > p) {break;} t /= p;



		} else {

		   	diffuse += t * getValFromSkyLUT(normalize(dir),  sunVector) * sky * accColor;
		   	break;

		   		
		}
	} else {
		diffuse += t * getValFromSkyLUT(normalize(dir),  sunVector) * sky;
		break;
	}
}
	 
	
    }




	specular = clamp(specular/SpecularSamples, 0.0, 65535.0);

	diffuse = clamp(diffuse/DiffuseSamples, 0.0, 65535.0);

	reflectedHitDist /= SpecularSamples;

	reservoirData = createReservoir(VoxelSpaceToSceneSpace(hitPos), hitMat.normal, diffuse, PI);
	

}

vec2 TAAneighbourhoodOffsets[8] = vec2[8](
	vec2(-1.0, -1.0),
	vec2( 0.0, -1.0),
	vec2( 1.0, -1.0),
	vec2(-1.0,  0.0),
	vec2( 1.0,  0.0),
	vec2(-1.0,  1.0),
	vec2( 0.0,  1.0),
	vec2( 1.0,  1.0)
);

float minDepth(sampler2D tex, vec2 coord) {
	float minD = texture(tex, coord).r;
		for(int i = 0; i < 8; i++) {
		vec2 offset = TAAneighbourhoodOffsets[i] * pixelSize;
		float temp = texture(tex, coord + offset).r;

		minD = min(temp, minD);
	}
	return minD;

}

const float[25] kernel = float[25](
	1.0f/256.0f,
    1.0f/64.0f,
    3.0f/128.0f,
    1.0f/64.0f,
    1.0f/256.0f,
    
    1.0f/64.0f,
    1.0f/16.0f,
    3.0f/32.0f,
    1.0f/16.0f,
    1.0f/64.0f,

    3.0f/128.0f,
    3.0f/32.0f,
    9.0f/64.0f,
    3.0f/32.0f,
    3.0f/128.0f,
   
    1.0f/64.0f,
    1.0f/16.0f,
    3.0f/32.0f,
    1.0f/16.0f,
    1.0f/64.0f,
    
    1.0f/256.0f,
    1.0f/64.0f,
    3.0f/128.0f,
    1.0f/64.0f,
    1.0f/256.0f
);

const vec2[25] offset = vec2[25](
    vec2(-2,-2),
    vec2(-1,-2),
    vec2(0,-2),
    vec2(1,-2),
    vec2(2,-2),
    
    vec2(-2,-1),
    vec2(-1,-1),
    vec2(0,-1),
    vec2(1,-1),
    vec2(2,-1),
    
    vec2(-2,0),
    vec2(-1,0),
    vec2(0,0),
    vec2(1,0),
    vec2(2,0),
    
    vec2(-2,1),
    vec2(-1,1),
    vec2(0,1),
    vec2(1,1),
    vec2(2,1),
    
    vec2(-2,2),
    vec2(-1,2),
    vec2(0,2),
    vec2(1,2),
    vec2(2,2)
);

const vec2[9] offset2 = vec2[9](
    vec2(-1,-1),
    vec2(0,-1),
    vec2(1,-1),
    vec2(-1,0),
    vec2(0,0),
    vec2(1,0),
    vec2(-1,1),
    vec2(0,1),
    vec2(1,1)
);

float spatialVarianceEstimate(sampler2D tex, vec2 coord) {

	float moment1,moment2,momentCount;

	for(int i = 0; i < 9; i++) {

		    vec2 offset = offset2[i]*pixelSize*2.;
            vec2 uv     = coord+offset;
            
            if(clamp(uv, vec2(0.0), vec2(TAAUres)) != uv) {continue;}
            
            vec4 ctmp  = texture(tex, uv);
            moment1 += luma(ctmp.rgb);
            moment2 += moment1*moment1;
            momentCount++;

	}

	    float mean = moment1/momentCount;
        float variance = moment2 / momentCount - pow2(mean);

	return variance;

}

vec3 FastCatmulRom(sampler2D colorTex, vec2 texcoord, vec4 rtMetrics, float sharpenAmount)
{
	if(floor(texcoord) != vec2(0.0)) return vec3(0.0);
    vec2 position = rtMetrics.zw * texcoord;
    vec2 centerPosition = floor(position - 0.5) + 0.5;
    vec2 f = position - centerPosition;
    vec2 f2 = f * f;
    vec2 f3 = f * f2;

    float c = sharpenAmount;
    vec2 w0 =        -c  * f3 +  2.0 * c         * f2 - c * f;
    vec2 w1 =  (2.0 - c) * f3 - (3.0 - c)        * f2         + 1.0;
    vec2 w2 = -(2.0 - c) * f3 + (3.0 -  2.0 * c) * f2 + c * f;
    vec2 w3 =         c  * f3 -                c * f2;

    vec2 w12 = w1 + w2;
    vec2 tc12 = rtMetrics.xy * (centerPosition + w2 / w12);
    vec3 centerColor = texture2D(colorTex, vec2(tc12.x, tc12.y)).rgb;

    vec2 tc0 = rtMetrics.xy * (centerPosition - 1.0);
    vec2 tc3 = rtMetrics.xy * (centerPosition + 2.0);
    vec4 color = vec4(texture2D(colorTex, vec2(tc12.x, tc0.y )).rgb, 1.0) * (w12.x * w0.y ) +
                   vec4(texture2D(colorTex, vec2(tc0.x,  tc12.y)).rgb, 1.0) * (w0.x  * w12.y) +
                   vec4(centerColor,                                      1.0) * (w12.x * w12.y) +
                   vec4(texture2D(colorTex, vec2(tc3.x,  tc12.y)).rgb, 1.0) * (w3.x  * w12.y) +
                   vec4(texture2D(colorTex, vec2(tc12.x, tc3.y )).rgb, 1.0) * (w12.x * w3.y );
    return color.rgb/color.a;

}

float acosApproximation(float x) {
   return (-0.69813170079773212 * x * x - 0.87266462599716477) * x + 1.5707963267948966;
}

float expApproximation(float x) {
	return 1.0/(pow2(x) - x + 1.0);
}

float computeExpWeight(float x, float px, float py) {
	return expApproximation(-3. * abs( x * px + py));
}


float getSpecularDominantFactor(float roughness, float NdotV) {
	float a = 0.298475 * log(39.4115 - 39.0029 * roughness);
	float f = pow(clamp01(1.0 - NdotV), 10.8649)*(1.0 - a) + a;
	return clamp01(f);

}


float getGeometryWeight(vec3 p0, vec3 p1, vec3 n, float pdn) {
	vec3 ray = p0 -p1;
	float dist = dot(n, ray);
	return clamp01(1.0 - abs(dist) * pdn);
}

float computeParallax(vec3 feetPos, vec3 prevFeetPos) {
	vec3 V1 = normalize(feetPos);
	vec3 V2 = normalize(prevFeetPos - (cameraPosition - previousCameraPosition));

	float cosA = clamp01(dot(V1, V2));

	float parallax = sqrt(1.0 - pow2(cosA)) / max(cosA, EPS);

	//parallax *= 60.;

	return parallax;
}

float calculateSpecularAccumulationSpeed(float maxA, float roughness, float NdotV, float parallax) {
	float acos01sq = 1.0 - NdotV;
	float a = pow(clamp01(acos01sq), 0.5);
	float b = 1.1 + pow2(roughness);

	float parallaxSensitivity = (b+a)/(b-a);
	float powerScale = 1.0 + parallax * parallaxSensitivity;
	float f = 1.0 - exp2(-200.0 * pow2(roughness));
	f *= pow(roughness, 0.8 * powerScale);
	float A = 32. * f;

	return min(A, maxA);
}


/* RENDERTARGETS:1,3,5,6,8 */
layout(location = 0) out vec4 irradianceBuffer;
layout(location = 1) out uvec4 temporalReservoirBuffer;
layout(location = 2) out vec4 nextgBufferData;
layout(location = 3) out vec4 momentBuffer;
layout(location = 4) out vec4 specularBuffer;

/*
const bool coloretex5MipmapEnabled = true;
*/


void main() {

	const vec2 texcoordNormalized = texcoord / TAAUres;
	const ivec2 texelPos = ivec2(texcoord * resolution);
	const ivec2 texelPosScaled = ivec2(texelPos * TAAUres);

	const ivec2 TAAUbound = ivec2(resolution * TAAUres);

	if(clamp(texelPos, ivec2(0), ivec2(TAAUbound)) != texelPos) return;

	float depth = texture(depthtex0, texcoordNormalized).r;
	//float depthA = minDepth(depthtex0, texcoord);

	vec3 viewPos = screenToView(vec3(texcoord, depth));

	vec3 prevCoord = vec3(toPrevScreenPos(texcoordNormalized, depth), toPrevViewScreenLinearized(texcoordNormalized , depth).z);

	vec2 velocity = prevCoord.xy - texcoordNormalized;
	//velocity -= (TAAoffsets[frameCounter%8]+TAAoffsets[(frameCounter-1)%8] )  * pixelSize;

	prevCoord.xy = texcoord + velocity * TAAUres;
	ivec2 prevTexelPos = ivec2(prevCoord.xy * resolution);
	//vec3 reflectedPos;
	float reflectedHitDist;


	uvec3 gBufferData = texture(colortex0, texcoordNormalized).rgb;	

	vec3 prevIrradiance  = FastCatmulRom(colortex1, prevCoord.xy, vec4(pixelSize, resolution), 0.5);
	vec4 prevgBufferData = texture(colortex5, prevCoord.xy);
	uvec4 temporalReservoirData = texture(colortex3, prevCoord.xy);
	float accumulation = texture(colortex6, prevCoord.xy).b;
	float specularAccumulation = texture(colortex6, prevCoord.xy).a;
	


	if(depth >= 1. ) {
		irradianceBuffer = vec4(getValFromSkyLUT(normalize(screenToFeet(vec3(texcoordNormalized,depth))),  sunVector)*sky , 1.);
		momentBuffer.g = clamp(1.0+accumulation, 0.0, 32.);
		return;
	}


	material mat;
	reservoir newReservoir;
	reservoir temporalReservoir;

	decodeGBuffer(mat, gBufferData);
	decodeReservoir(temporalReservoir, temporalReservoirData);
	
	bool outScreen = (clamp(prevCoord.xy, vec2(0.0), vec2(TAAUres)) != prevCoord.xy);
	float d0 = toViewSpaceDepth(prevCoord.z);
	float d1 = toViewSpaceDepth(prevgBufferData.a);
	float depthWeight  = pow(exp(-abs(d0-d1)*0.55), 2.);//float(float(abs(d0 - d1) / abs(d0) < 0.1));// 
	float normalWeight = pow(max0(dot(getGeometryNormal(mat3(gbufferModelViewInverse) * (prevgBufferData.rgb * 2.0 - 1.0)), getGeometryNormal(mat3(gbufferModelViewInverse) * mat.normal))), 1.);
	float totalWeight  = float(!outScreen ) * normalWeight * depthWeight;


	

	accumulation = clamp(accumulation+1.0, 0.0, 32.) * totalWeight;

	float frameWeight = 1.0-(1.0 / (accumulation+1.0));




	bool isSpecularBounce = false;
	vec3 diffuse = vec3(0.0);
	vec3 specular = vec3(0.0);

	calculateIrradiance(mat, depth, frameWeight, newReservoir, isSpecularBounce, reflectedHitDist, diffuse, specular);
	temporalReservoir.M = clamp(temporalReservoir.M, 0, int((7*((totalWeight*frameWeight*pow(max0(dot(prevgBufferData.rgb * 2.0 - 1.0, mat.normal)), 1.)))* (exp(-length((prevTexelPos - texelPos))) * 0.2 + 0.4))));//int((500*((totalWeight*frameWeight*pow(max0(dot(prevgBufferData.rgb * 2.0 - 1.0, mat.normal)), 1.)* (exp(-length((prevTexelPos - texelPos))) * 0.2 + 0.2)))))

	float f = getSpecularDominantFactor(mat.roughness, clamp01(dot(mat.normal, normalize(-viewPos))));


	//float Asurface = calculateSpecularAccumulationSpeed(accumulation, mat.roughness,  clamp01(dot(mat.normal, normalize(-viewPos))), computeParallax(screenToFeet(vec3(texcoord, depth)), screenToWorld(vec3(texcoord, depth))-cameraPosition ));

	//reflectedHitDist = mix(max0(reflectedHitDist), texture(colortex6, prevCoord.xy).b, frameWeight);

	vec3 reflectedPos = viewToScreen(viewPos + normalize(viewPos) * reflectedHitDist * f);

	vec3 prevReflectedPos = vec3(toPrevScreenPos(reflectedPos.xy/TAAUres, reflectedPos.z), toPrevViewScreenLinearized(reflectedPos.xy/TAAUres, reflectedPos.z).z);
	vec2 reflectedVelocity = prevReflectedPos.xy - reflectedPos.xy/TAAUres;
	prevReflectedPos.xy = (reflectedPos.xy + reflectedVelocity*TAAUres);
	ivec2 prevReflectedTexelPos = ivec2( prevReflectedPos.xy * resolution);

	vec3 ndx = dFdx(mat.normal);
	vec3 ndy = dFdy(mat.normal);
	float ncurvature = pow(max(dot(ndx, ndx), dot(ndy, ndy)), 0.5);
	//float specularDepthWeight  =  mix(1.0, clamp01(pow(exp(-abs(toViewSpaceDepth(textureLod(colortex5, prevReflectedPos.xy, 0.).a)-toViewSpaceDepth(texture(colortex5, prevCoord.xy).a))),mix(8.0, 2.0, pow(mat.roughness, 1.0)))), 1.);//1.;

	prevReflectedPos.xy = mix(prevReflectedPos.xy, prevCoord.xy, ncurvature);

	vec3 prevSpecular = max0(FastCatmulRom(colortex9, prevReflectedPos.xy, vec4(pixelSize, resolution), 0.4));

	float specularNormalWeight = clamp(pow(max0(dot( ((texture(colortex5, prevReflectedPos.xy).rgb*2.0-1.0)),  mat.normal)), 1.), 0.0, 1.0);
	float specularRoughnessWeight = pow(exp(-abs(mat.roughness - texture(colortex6, prevReflectedPos.xy).r)), 12.);
	float specularTotalWeight = (pow(mat.roughness, 0.3) *specularNormalWeight* specularRoughnessWeight * float((clamp(prevReflectedPos.xy, vec2(0.0), vec2(TAAUres)) == prevReflectedPos.xy)) );

	specularAccumulation = clamp(specularAccumulation+1.0, 0.0, 8.0) * specularTotalWeight;
	float specularAccumulationWeight = 1.0-(1.0/ ( specularAccumulation+1.0));



	float tf = luma(temporalReservoir.radiance);
	float Wt = max0(temporalReservoir.avgW)* temporalReservoir.M * tf;

	float pNew = luma(diffuse);
	float weight = pNew * newReservoir.avgW;

	bool update = updateReservoir(newReservoir, temporalReservoir, weight, Wt);

	float avgWSum =  temporalReservoir.M == 0 ? 0. : Wt/(temporalReservoir.M);

	pNew = luma(temporalReservoir.radiance);
	temporalReservoir.avgW = pNew <= 0.0 ? 0.0 : avgWSum / pNew;

	encodeReservoir(temporalReservoirBuffer, temporalReservoir);

	#ifdef TemporalResampling
		vec3 irradiance =  temporalReservoir.radiance * temporalReservoir.avgW / PI;

	#else
		vec3 irradiance = diffuse;
	#endif

//irradiance /= (luma(irradiance)+1.);
	#ifdef TemporalFilter
	 	irradiance = mix(irradiance, prevIrradiance.rgb, frameWeight);

	 	specular = mix(specular.rgb, prevSpecular, specularAccumulationWeight );

	#endif
		float lum = luma(irradiance);

		//float secondMoment = mix(pow2(luma(irradiance.rgb)), prevSecondMoment,frameWeight);

	vec2 moments = mix(vec2(lum, pow2(lum)), vec2(luma(prevIrradiance), texture(colortex6, prevCoord.xy).g), frameWeight*0.9);

	float variance = mix(spatialVarianceEstimate(colortex1, prevCoord.xy)*0.01, max0(moments.y - pow2(moments.x)), min(1.0, accumulation/4.));


	irradianceBuffer = vec4(irradiance, sqrt(variance));

	nextgBufferData = vec4(mat.normal*0.5+0.5, (depth));

	//TODO : MOVE ALBEDO TO THIS INSTEAD ^
	//uvec3 albedo = uvec3(mat.albedo*255.);
	//float albedoData = float((albedo.r << 16u) | (albedo.g << 8u) | (albedo.b ));



	specularBuffer = vec4(specular, mat.roughness);
	//can also do neighbourhood clamping but lazy

	momentBuffer= vec4(mat.roughness, moments.y, accumulation, specularAccumulation);


}