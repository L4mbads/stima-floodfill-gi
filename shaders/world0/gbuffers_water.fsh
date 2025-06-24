#version 430 compatibility

#extension GL_ARB_explicit_attrib_location : enable

uniform float alphaTestRef;
uniform sampler2D gtexture;
uniform sampler2D normals;
uniform sampler2D specular;
uniform sampler2D lightmap;
uniform sampler2D colortex7;
uniform sampler2D depthtex0;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex1;
uniform vec3 sunPosition;
uniform int frameCounter;
uniform vec2 resolution;

#include "/lib/Settings.glsl"
#include "/lib/Random.glsl"
#include "/lib/Encoding.glsl"
#include "/lib/Projection.glsl"
#include "/lib/BRDF.glsl"

in vec2 lmcoord;
in vec2 texcoord;
in vec4 tint;
in mat3 tbn;
in float water;

/* DRAWBUFFERS:8 */
layout(location = 0) out vec4 colortex0Out;

void main() {
	vec4 color = texture(gtexture, texcoord) * tint;
	if (color.a < alphaTestRef) discard;
	float depth = texture(depthtex0, texcoord).r;
	vec4 specularTex = texture(specular, texcoord);
	vec4 normalTex = texture(normals, texcoord);
	//color *= texture(lightmap, lmcoord);
	color.rgb *= sRGBtoAP1;

	vec3 screen   = vec3(gl_FragCoord.xy/resolution, depth);
    vec3 feet = screenToFeet(screen);

    vec3 shadowPos = feetToShadowScreen(feet);

    vec3 viewPos = screenToView(screen);
    vec3 L = normalize(sunPosition);
    vec3 V = -normalize(viewPos);
   	vec3 N = decodeNormal(normalTex.xy, tbn);
    vec3 H = normalize(L + V);
    float NdotL = max0(dot(N, L));

    vec3 R = reflect(-V, N);
    float NdotR = max0(dot(N, R));

    vec3 fresnel = fresnelSchlick(clamp01(dot(N, V)), vec3(water>0.0?5./255.:0.04));
    vec3 directSpecular = BRDFCookTorrance(N, V, L, water>0.0?0.0:1.0, fresnel);

    vec3 v1 = calculateShadow(shadowtex1, shadowPos, 0.0000);

    vec3 refracted = (1.0-fresnel) * color.rgb * texture(colortex7, gl_FragCoord.xy/resolution*TAAUres).rgb;

	color.rgb = refracted;


	colortex0Out = vec4(color);
}