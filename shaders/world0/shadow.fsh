#version 430 compatibility

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform mat4 shadowModelViewInverse;
uniform vec3 cameraPosition;
uniform usampler2D shadowcolor1;
uniform sampler2D shadowcolor0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform int frameCounter;
uniform vec2 resolution;
uniform vec3 sunVector;

/* RENDERTARGETS:0,1 */

layout (location = 0) out vec4 shadowcolor0Write;
layout (location = 1) out uvec2 shadowcolor1Write;


#include "/lib/Settings.glsl"

// Voxel buffer inputs
in vec4  fData0;
in vec4  fData1;
in float isVoxel;
// Shadow buffer inputs
in vec3 tint;
in vec2 textureCoordinates;
in vec2 lightmapCoordinates;


#include "/lib/Random.glsl"
#include "/lib/Encoding.glsl"
#include "/lib/Voxelization.glsl"
#include "/lib/Voxel_Intersect.glsl"

void main() {
    if (isVoxel > 0.5) { // Voxels
       

        ivec3 origin = StoragePosToVoxelSpace(ivec2(gl_FragCoord.xy));

        //bool sunVis = !RaytraceVoxelShadows(origin, ivec3(floor(origin + sunVector * 0.1)),  sunVector, true, 50);

        shadowcolor0Write = texelFetch(shadowcolor0, ivec2(gl_FragCoord.xy), 0);

        shadowcolor1Write = uvec2(packUnorm4x8(fData0), packUnorm4x8(fData1));
    } else {
        vec4 albedo = textureLod(texture, textureCoordinates, 0.0);
        if (albedo.a < 0.5) discard;
        albedo.rgb *= tint;

        shadowcolor0Write = albedo;
        shadowcolor1Write = uvec2(0);
    }
}