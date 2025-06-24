#extension GL_ARB_explicit_attrib_location : enable

#include "/lib/Settings.glsl"

#if defined(vertex)

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 textureMatrix = mat4(1.0);
uniform vec3 chunkOffset;
uniform int frameCounter;
uniform vec2 pixelSize;
uniform int hideGUI;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;


in vec4 at_tangent;
in vec3 mc_Entity;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 tint;
out mat3 tbn;
out float water;
out vec3 normal;

void main() {
	gl_Position = gl_ProjectionMatrix * vec4((gl_ModelViewMatrix * gl_Vertex).xyz, 1.0);
	//gl_Position.xy = gl_Position.xy * TAAUres + TAAUres * gl_Position.w - gl_Position.w;

	#ifdef TemporalAA
		vec3 diff = cameraPosition-previousCameraPosition;
		float velocity = sqrt(pow2(diff.x) + pow2(diff.y) + pow2(diff.z));
		gl_Position.xy += TAAoffsets[frameCounter%8] * pixelSize * gl_Position.w ;
	#endif
	texcoord    = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord     = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	tint        = gl_Color;

	normal = normalize(gl_NormalMatrix * gl_Normal);
    vec3 tangent = normalize(gl_NormalMatrix * (at_tangent.xyz / at_tangent.w));
    vec3 bitangent = cross(tangent, normal);

    tbn = mat3(
        tangent,
        bitangent,
        normal
    );

    water = float(floor(mc_Entity.x+0.5) == 252)*1.;
}

#elif defined(fragment)

uniform float alphaTestRef;
uniform sampler2D gtexture;
uniform sampler2D normals;
uniform sampler2D specular;
uniform sampler2D lightmap;
uniform vec2 resolution;
uniform int frameCounter;
uniform sampler2D colortex1;
uniform mat4 gbufferModelViewInverse;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 tint;
in mat3 tbn;
in float water;
in vec3 normal;

#include "/lib/Random.glsl"
#include "/lib/Encoding.glsl"


/* RENDERTARGETS:0 */
layout(location = 0) out uvec3 gBufferData;


void main() {


	vec4 colorTex    = texture(gtexture, texcoord) * vec4(tint.rgb, 1.0);
	vec4 normalTex   = texture(normals,  texcoord);
	vec4 specularTex = texture(specular, texcoord);
		 

	if ((colorTex.a < alphaTestRef)) discard;

	vec4 flatNormal = vec4(normal.xy, normalTex.zw);


	encodeGBuffer(gBufferData, colorTex, normalTex,mat3(gbufferModelViewInverse)* normal, specularTex, tbn, randF(), water);	
	
}

#endif