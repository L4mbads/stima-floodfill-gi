
#version 430 compatibility
#include "/lib/Settings.glsl"

/*RENDERTARGETS:7*/
layout (location = 0) out vec4 colortex7Out;




in vec2 texcoord;

uniform sampler2D colortex7;
uniform sampler2D colortex1;
uniform sampler2D colortex8;
uniform usampler2D colortex0;
uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D colortex13;
uniform sampler2D shadowtex1;
uniform float screenBrightness;
uniform vec2 pixelSize;
uniform sampler2D shadowcolor0;
uniform vec3 sunPosition;
uniform int frameCounter;
uniform vec2 resolution;
uniform vec3 sunVector;


#include "/lib/Random.glsl"
#include "/lib/Encoding.glsl"

#include "/lib/Projection.glsl"
#include "/lib/BRDF.glsl"
#include "/lib/Atmosphere.glsl"
const vec3 sun = (vec3(12000.) * (vec3(1.0, 0.89, 0.85) * sRGBtoAP1));
const vec3 sky = vec3(47.*100.);
const vec3 sunTransmittance = getValFromTLUT(colortex13, resolution, vec3(0.0, groundRadiusMM + 0.000063, 0.0), sunVector);

/*
const bool colortex7MipmapEnabled = true;
*/
void main() {
     

    if(clamp(texcoord, vec2(0.0), vec2(TAAUres)) != texcoord) return;

    float depth = texture(depthtex0, texcoord/TAAUres).r;
    vec4 color = texture(colortex7, texcoord);
    vec4 transparent = texture(colortex8, texcoord/TAAUres);
colortex7Out = mix(color, transparent, transparent.a);
return;
    if(depth >= 1.0) return;
    uvec3 gBufferData = texture(colortex0, texcoord/TAAUres).rgb;
    material mat;
    decodeGBuffer(mat, gBufferData);
    
    if(!mat.isTransparent) return;

    vec3 screen   = vec3(texcoord/TAAUres, depth);
    vec3 feet = screenToFeet(screen);

    vec3 shadowPos = feetToShadowScreen(feet);

    vec3 viewPos = screenToView(screen);
    vec3 L = normalize(sunPosition);
    vec3 V = -normalize(viewPos);
    vec3 N = mat.normal;
    vec3 H = normalize(L + V);
    float NdotL = max0(dot(N, L));

    vec3 R = reflect(-V, N);
    float NdotR = max0(dot(N, R));

    vec3 fresnel = fresnelSchlick(clamp01(dot(N, V)), vec3(mat.isWater?5./255.:mat.f0));
    vec3 directSpecular = BRDFCookTorrance(N, V, L, mat.isWater ?0.0:mat.roughness, fresnel);

    vec3 v1 = calculateShadow(shadowtex1, shadowPos, 0.0003);

    float waterDepth = toViewSpaceDepth(depth)-toViewSpaceDepth(texture(depthtex1, texcoord/TAAUres).r);

    vec3 refracted = textureLod(colortex7,texcoord, !mat.isWater?0.0:waterDepth*0.2).rgb * (1.0-mat.opacity);

    //vec2 refractedPos = texcoord + viewToScreen(refract(-V, N, 1./1.3)).xy*pixelSize*30.;
    //refractedPos = abs(toViewSpaceDepth(texture(depthtex1, refractedPos).r) - toViewSpaceDepth(texture(depthtex0, refractedPos).r)) < 5. ? texcoord : refractedPos * TAAUres;
    //refractedPos = (clamp(refractedPos, vec2(0.0), vec2(TAAUres)) != refractedPos) ? texcoord : refractedPos;
    colortex7Out.rgb = mix(refracted, refracted*mat.albedo, 1.0-mat.opacity)* (mat.isWater ? exp( -( abs(waterDepth) ) * 3.5* vec3(0.3, 0.04, 0.025)) : vec3(1.0)) ;

    colortex7Out.rgb = colortex7Out.rgb*(1.0-fresnel) ;

        
}

