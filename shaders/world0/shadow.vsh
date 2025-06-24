#version 430 compatibility

uniform sampler2D texture;
uniform mat4 shadowModelViewInverse;
uniform sampler2D shadowcolor0;

#define attribute in


attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
attribute vec4 at_tangent;
attribute vec3 at_midBlock;
attribute ivec2 vaUV2;  

out vec3  vertexProj;
out vec3  vertexNormal;
out vec3  vertexTint;
out vec3  midBlock;
out vec2  texcoord;
out vec2  lmcoord;
out vec2  midcoord;
out vec3 vertexPosition;
out vec3 tangent;
out vec3 normal;
out vec3 bitangent;
out float isNotOpaque;
flat out int   blockID;

#include "/lib/Projection.glsl"

float signNZ(float x) {
    return x < 0.0 ? -1.0 : 1.0;
}

void main() {

    gl_Position = gl_ModelViewMatrix * gl_Vertex;

    vertexProj     = (shadowModelViewInverse * gl_Position).xyz;
    vertexNormal   = normalize(mat3(shadowModelViewInverse) * gl_NormalMatrix * gl_Normal);
    vertexTint     = gl_Color.rgb;
    midBlock       = at_midBlock / 64.0;
    texcoord       = gl_MultiTexCoord0.xy;
    lmcoord        = vaUV2 * (1.0 / 256.0) + (1.0 / 32.0);
    midcoord       = mc_midTexCoord.xy;
    blockID        = int(mc_Entity.x);

    vertexPosition = gl_Vertex.xyz;
    normal = gl_Normal;
    tangent = at_tangent.xyz;
    bitangent  = cross(tangent, normal) * signNZ(at_tangent.w);

   gl_Position     = gl_ProjectionMatrix * gl_Position;
   gl_Position.xyz = gl_Position.xyz / vec3(vec2(distortionFactor(gl_Position.xy)), Shadow_Z_Stretch);

    if (blockID == 0) {
        isNotOpaque = 1.0;
    } else {
        isNotOpaque = 0.0;
        blockID = max(blockID, 1);
    }
}