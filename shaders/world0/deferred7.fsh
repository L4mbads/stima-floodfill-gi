#version 430
#extension GL_ARB_explicit_attrib_location : enable

in vec2 texcoord;
uniform usampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex7;
uniform sampler2D colortex9;
uniform sampler2D colortex5;
uniform sampler2D colortex2;
uniform sampler2D colortex6;
uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform sampler2D depthtex2;
uniform sampler2D colortex13;
uniform sampler2D colortex8;
uniform usampler2D shadowcolor1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex1;

uniform vec2 resolution;
uniform int frameCounter;
uniform vec2 pixelSize;
uniform vec3 sunVector;
uniform vec3 moonVector;
uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform vec3 moonPosition;
uniform float frameTime;
uniform float screenBrightness;


#include "/lib/Settings.glsl"
#include "/lib/Random.glsl"
#include "/lib/Encoding.glsl"
#include "/lib/Projection.glsl"
#include "/lib/Atrous.glsl"
#include "/lib/Voxelization.glsl"
#include "/lib/Atmosphere.glsl"
#include "/lib/BRDF.glsl"


const vec3 sun = (vec3(6000.) * (vec3(1.0, 0.89, 0.85) * sRGBtoAP1));

const vec3 moon = (vec3(6.) * (vec3(1.0, 0.89, 0.85) * sRGBtoAP1));
const vec3 sky = vec3(47.*100.);
const vec3 skySampled = getValFromSkyLUT(normalize(mat3(gbufferModelViewInverse) * normalize(upPosition-0.05)),  sunVector) * sky;
const vec3 sunTransmittance = getValFromTLUT(colortex13, resolution, vec3(0.0, groundRadiusMM + 0.000063, 0.0), sunVector);

vec2[8] TAAneighbourhoodOffsets = vec2[8](
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

vec4 sampleTextureCatmullRom4Samples(sampler2D tex, vec2 uv, vec2 texSize, out float weight)
{
    // Based on the standard Catmull-Rom spline: w1*C1+w2*C2+w3*C3+w4*C4, where
    // w1 = ((-0.5*f + 1.0)*f - 0.5)*f, w2 = (1.5*f - 2.5)*f*f + 1.0,
    // w3 = ((-1.5*f + 2.0)*f + 0.5)*f and w4 = (0.5*f - 0.5)*f*f with f as the
    // normalized interpolation position between C2 (at f=0) and C3 (at f=1).

    // half_f is a sort of sub-pixelquad fraction, -1 <= half_f < 1.
    vec2 half_f     = 2.0 * fract(0.5 * uv * texSize - 0.25) - 1.0;

    // f is the regular sub-pixel fraction, 0 <= f < 1. This is equivalent to
    // fract(uv * texSize - 0.5), but based on half_f to prevent rounding issues.
    vec2 f          = fract(half_f);

    vec2 s1 	    = ( 0.5 * f - 0.5) * f;            // = w1 / (1 - f)
    vec2 s12        = (-2.0 * f + 1.5) * f + 1.0;      // = (w2 - w1) / (1 - f)
    vec2 s34        = ( 2.0 * f - 2.5) * f - 0.5;      // = (w4 - w3) / f

    // positions is equivalent to: (floor(uv * texSize - 0.5).xyxy + 0.5 +
    // vec4(-1.0 + w2 / (w2 - w1), 1.0 + w4 / (w4 - w3))) / texSize.xyxy.
    vec4 positions  = vec4((-f * s12 + s1      ) / (texSize * s12) + uv,
     				       (-f * s34 + s1 + s34) / (texSize * s34) + uv);

    // Determine if the output needs to be sign-flipped. Equivalent to .x*.y of
    // (1.0 - 2.0 * floor(t - 2.0 * floor(0.5 * t))), where t is uv * texSize - 0.5.
    float sign_flip = half_f.x * half_f.y > 0.0 ? 1.0 : -1.0;

    vec4 w 		    = vec4(-f * s12 + s12, s34 * f); // = (w2 - w1, w4 - w3)
    vec4 weights    = vec4(w.xz * (w.y * sign_flip), w.xz * (w.w * sign_flip));

    weight = max4(weights.x,weights.y,	weights.z,weights.w);

    return texture(tex, positions.xy) * weights.x +
           texture(tex, positions.zy) * weights.y +
     	   texture(tex, positions.xw) * weights.z +
           texture(tex, positions.zw) * weights.w;
}

vec3 FastCatmulRom(sampler2D colorTex, vec2 texcoord, vec4 rtMetrics, float sharpenAmount, out float weight)
{
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

    weight = max4(w0.x, w1.x, w2.x, w3.x) * max4(w0.y, w1.y, w2.y, w3.y);

    vec2 tc0 = rtMetrics.xy * (centerPosition - 1.0);
    vec2 tc3 = rtMetrics.xy * (centerPosition + 2.0);
    vec4 color = vec4(texture2D(colorTex, vec2(tc12.x, tc0.y )).rgb, 1.0) * (w12.x * w0.y ) +
                   vec4(texture2D(colorTex, vec2(tc0.x,  tc12.y)).rgb, 1.0) * (w0.x  * w12.y) +
                   vec4(centerColor,                                      1.0) * (w12.x * w12.y) +
                   vec4(texture2D(colorTex, vec2(tc3.x,  tc12.y)).rgb, 1.0) * (w3.x  * w12.y) +
                   vec4(texture2D(colorTex, vec2(tc12.x, tc3.y )).rgb, 1.0) * (w12.x * w3.y );
	return color.rgb/color.a;

}
//FIX THIS SHIT
vec3 TAAneighbourhoodClamp(vec3 color, sampler2D prevTex, vec2 coord, float depth, out float weight, inout float edge) {
	vec3 minCol = color;
	vec3 maxCol = color;

	//vec3 prevColor = sampleTextureCatmullRom4Samples(prevTex, coord, pixelSize, weight).rgb;
	vec3 prevColor = FastCatmulRom(prevTex, coord, vec4(pixelSize, resolution), 0.75, weight).rgb;
	//vec3 prevColor = texture(prevTex, coord).rgb;
	if(prevColor == vec3(0.0)) return color;

	for(int i = 0; i < 8; i++) {
		vec2 offset = TAAneighbourhoodOffsets[i] * pixelSize;

		float depthCheck = toViewSpaceDepth(texture(colortex5, coord + offset, 0).a);
		if (abs(depthCheck - depth) > 0.09) {
			edge = 20.;
		}

		
		vec3 temp = texture(prevTex, coord + offset).rgb;

		minCol = min(temp, minCol);
		maxCol = max(temp, maxCol);
	}

	return YCoCgtosRGB * clamp(sRGBtoYCoCg * prevColor, sRGBtoYCoCg * minCol, sRGBtoYCoCg * maxCol);
}

void TAATonemap(inout vec3 color) {
	float lum = 1.0 / (1.0 + luma(color));
	color *= lum;
}

void TAAinvTonemap(inout vec3 color) {
	float lum = 1.0 / (1.0 - luma(color));
	color *= lum;
}

vec3 TAAresolve(vec3 color, sampler2D prevTex, vec2 coord, vec2 prevCoord, float depth, float a) {


	if(clamp(prevCoord, vec2(0.0), vec2(1.0)) != prevCoord) return color;

	vec2 velocity = (texcoord - prevCoord) * resolution;

	//velocity -= (TAAoffsets[frameCounter%8]+TAAoffsets[(frameCounter-1)%8] )  * pixelSize;
	float confidence;
	float edge = 0.0;
	vec3 prevColor = max(TAAneighbourhoodClamp(color, prevTex, prevCoord, depth, confidence, edge), vec3(0.0));
	float weight = exp(-length(velocity) ) * 0.6 + 0.3;
	
	float blendMinimum = 0.3;
	float blendVariable = 0.25;
	float blendConstant = 0.65;
	float velocityFactor = dot(velocity, velocity) * 10.0;
	float blendFactor = max(exp(-velocityFactor) * blendVariable + blendConstant - length(cameraPosition - previousCameraPosition) * edge, blendMinimum);
	
	TAATonemap(color);
	TAATonemap(prevColor);




	vec3 result = mix(color,  prevColor,  clamp(confidence, 0.1, 0.9) );
	//vec3 result = current.rgb * 0.1 * current.a + previous.rgb * previous.a * 0.9;

	TAAinvTonemap(result);

	return result;

}



/*
float3 SMAABicubicFilter(float3 currentNeighborhood[4], float3 currentCenterColor, float3 previousCenterColor,
                         float2 texcoord, float4 rtMetrics, float sharpnessScale)
{
    float2 f = frac(rtMetrics.zw * texcoord - 0.5);
 
    float c = 0.8 * sharpnessScale * SMAA_FILMIC_REPROJECTION_SHARPNESS / 100.0;
    float2 w = c * (f * f - f);

    #if SMAA_REFERENCE_CODE
    float3 currentColorH = lerp(currentNeighborhood[SMAA_NEIGHBORHOOD_WEST],  currentNeighborhood[SMAA_NEIGHBORHOOD_EAST],  f.x);
    float3 currentColorV = lerp(currentNeighborhood[SMAA_NEIGHBORHOOD_NORTH], currentNeighborhood[SMAA_NEIGHBORHOOD_SOUTH], f.y);

    float4 color = float4(previousCenterColor + currentColorH - currentCenterColor, 1.0) * w.x +

                   float4(previousCenterColor + currentColorV - currentCenterColor, 1.0) * w.y +

                   float4(previousCenterColor, 1.0);
    #else
    float4 color = float4(lerp(currentNeighborhood[SMAA_NEIGHBORHOOD_WEST],  currentNeighborhood[SMAA_NEIGHBORHOOD_EAST],  f.x), 1.0) * w.x +
                   float4(lerp(currentNeighborhood[SMAA_NEIGHBORHOOD_NORTH], currentNeighborhood[SMAA_NEIGHBORHOOD_SOUTH], f.y), 1.0) * w.y;
    color += float4((1.0 + color.a) * previousCenterColor - color.a * currentCenterColor, 1.0);
    #endif
 
    return color.rgb * rcp(color.a);
}


/*RENDERTARGETS:7,1,9,8*/
layout(location = 0) out vec3 colortex4Out;
layout(location = 1) out vec4 colortex1Out;
layout(location = 2) out vec4 specular;
layout(location = 3) out vec4 colortex8Out;


void main() {
	if(clamp(texcoord, vec2(0.0), vec2(TAAUres)) != texcoord) return;

	colortex8Out = vec4(0.0);
	float depth = texture(depthtex0, texcoord/TAAUres).r;
	//float depth = minDepth(depthtex1, texcoord*TAAUres);
	vec4 currData = texture(colortex7, texcoord);

	//FastCatmulRom(colortex7, texcoord*TAAUres, vec4(pixelSize, resolution), 0.75).rgb;


	uvec3 gBufferData = texture(colortex0, texcoord/TAAUres).rgb;
	specular = texture(colortex8, texcoord);

	material mat;

	decodeGBuffer(mat, gBufferData);

	vec3 screen   = vec3(texcoord/TAAUres, depth);

	vec3 viewPos = screenToView(screen);

	vec3 feet = screenToFeet(screen);

	vec3 origin = SceneSpaceToVoxelSpace( feet ) + getGeometryNormal(mat3(gbufferModelViewInverse)* mat.normal)*0.05;

    vec3 shadowPos = feetToShadowScreen(feet);
    #ifdef DebugIC
		colortex4Out.rgb =  texelFetch(colortex2, GetVoxelStoragePos(ivec3(floor(origin))), 0).rgb;return;
	#endif
	vec2 prevCoord = toPrevScreenPos(texcoord/TAAUres, depth);

	vec2 v = prevCoord - texcoord;


	float prevDepth = texture(colortex5, (texcoord + v)).a;


	vec3 d = normalize(feet);
	 
	float steps = 8.;
	vec3 increment = (feet- gbufferModelViewInverse[3].xyz) / steps;
	float dither = fract(fract(frameCounter * (1.0 / GOLDEN_RATIO)) + Bayer16(gl_FragCoord.xy));
	vec3 scenePosition = gbufferModelViewInverse[3].xyz + increment * dither;
	float stepSize = length(increment);

	vec3 shadowIncrement  = mat3(shadowModelView) * increment;
	 	  shadowIncrement *= vec3(shadowProjection[0].x, shadowProjection[1].y, shadowProjection[2].z);
/*
	vec3 shadowPosition = mat3(shadowModelView) * feetToShadowScreen(gbufferModelViewInverse[3].xyz) + shadowModelView[3].xyz;
	 	  shadowPosition = mat3(shadowProjection) * shadowPosition + shadowProjection[3].xyz;
	 	  shadowPosition += shadowIncrement * dither;
*/
	vec3 fog = vec3(0.0);
	float t = 1.0;
	float density = 0.009;
	for(int i = 0; i < steps  ; i++, scenePosition += increment) {//, shadowPosition += shadowIncrement
	 	//pow(texelFetch(shadowcolor0, GetVoxelStoragePos(ivec3(floor(SceneSpaceToVoxelSpace(scenePosition + randomDirection()*0.5 )))), 0).rgb * 10., vec3(0.8)) * 0.25 * invPI + 
	 	//float density = max(-2/max(EPS,scenePosition.y+cameraPosition.y), 0.0);
	 	fog +=  density * stepSize * t * (  (calculateShadow(shadowtex1, feetToShadowScreen(scenePosition), 0.000) * sun  * sunTransmittance  * henyeyGreenstein(0.7, dot(d, sunVector ))));
	 	t *= exp(-stepSize * density * 1.0);
	 	if (t < EPS) break;
	}

	steps = 24;
	increment = normalize(feet) * 6.;
	scenePosition = gbufferModelViewInverse[3].xyz + increment * dither;
	stepSize = length(increment);
	density = 0.5;
	t = 1.0;
	for(int i = 0; i < steps && (length(scenePosition) < length(feet)); i++, scenePosition += increment) {
		fog += density * t * pow( texelFetch(colortex2, GetVoxelStoragePos(ivec3(floor(SceneSpaceToVoxelSpace(scenePosition + randomDirection()*0.5 )))), 0).rgb*1.0, vec3(0.4)) * 0.25 * invPI;
		t *= exp(-stepSize * density * .01);
		if (t < EPS) break;
	}

	fog +=  skySampled*(1.0-exp(-.00015*abs(viewPos.z)));

	if(depth >= 1.0) {colortex4Out = ((currData.rgb+fog)); return;}


	vec4 indirect = atrous(colortex7, colortex8, colortex5, depth, texcoord, 4, false, texture(colortex6, texcoord).g, specular.rgb);

	

	/*
	uint albedoData = uint(texelFetch(colortex8, ivec2(texcoord*resolution*TAAUres), 0).a);

	vec3 opaqueAlbedo = (vec3( (albedoData >> 16u) & 255u, 
                              (albedoData >> 8u) & 255u,
                              (albedoData ) & 255u)
                              /255.);
	*/

	float frame = texture(colortex6, texcoord).b;
	//float weight =  1.0-(frame/(frame +1.0));
	float weight = min(1.0, frame/8.);


	vec3 L = normalize(sunPosition);
	vec3 V = -normalize(viewPos);
	vec3 N = mat.normal;
	vec3 H = normalize(L + V);

	float NdotL = max0(dot(N, L));

	vec3 vis;
	float sunDepth;
	float cosT = cos(dither);
	float sinT = sin(dither);
	mat2 rot = mat2(cosT, -sinT, sinT, cosT) / shadowMapResolution;
	for(int i = 0; i < ShadowSamples; i++) {
		vis += calculateShadow(shadowtex1, shadowPos + vec3(rot * PoissonDisk2[(i+frameCounter)%64], 0.0), 0.00025, sunDepth);//!RaytraceVoxelShadows2(origin, ivec3(floor(origin)),  sunVector, false, 200);
	}
	vis /= ShadowSamples;
	sunDepth = max0(1.0- (max(sunDepth / ShadowSamples, 0.0)));

	vec3 fresnel = fresnelSchlick(clamp01(dot(N, V)), mix(vec3(mat.f0), mat.albedo, mat.isMetal));
	
	vec3 directSpecular = BRDFCookTorrance(N, V, L, mat.roughness, fresnel);

	vec3 kd = vec3(1.0 - fresnel) * float(!mat.isMetal);

	vec3 emission = mat.albedo*max(mat.emission, 0.25);

	float dist = distance(toShadowViewSpaceDepth(sunDepth), toShadowViewSpaceDepth(shadowPos.z));

	vec3 sssDepth;
	for(int i = 0; i < 11 ; i++) {
	sssDepth += calculateShadow(shadowtex1, shadowPos+vec3(0.0016*SSSFalloff*(randF()*2.0-1.0),0.0016*SSSFalloff*(randF()*2.0-1.0),0.0), 0.005*SSSIntensity*(1.0-mat.sss));
	}

	vec3 sss = computeTransmission(mat, sunDepth, (dot(H, V))) * mat.albedo * sssDepth/10;


	vec3 direct = ((kd*(mat.albedo/PI) + directSpecular)  * NdotL  * (vis) + sss) * sun * sunTransmittance;
		 //direct += ((kd*(mat.albedo/PI)) * max0(dot(N, normalize(moonPosition))) * vis) * moon * sunTransmittance;
	//indirect.rgb /= (1.0-(luma(indirect.rgb)));


	vec3 radiance;

		 radiance += vec3(0.0)

		 #ifdef DirectLight 
		 		  + direct
		 #endif

		 #ifdef Emission
				  + emission
		 #endif

		 #ifdef IndirectLight
		 		  + indirect.rgb * mat.albedo
		 #endif

		 #ifdef Specular 
			      + specular.rgb * (!mat.isMetal ? vec3(1.0) : mat.albedo)
		 #endif

		 #ifdef Fog		  
				  + fog   
		 #endif
				  ;
		specular.rgb = mix(texture(colortex9, texcoord).rgb, specular.rgb, 1.0-(weight));

	colortex4Out = radiance;
	colortex1Out = mix(texture(colortex1, texcoord), indirect, 1.0-(weight));

}
