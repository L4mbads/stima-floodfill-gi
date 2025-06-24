#version 430 compatibility

uniform sampler2D texture;
uniform usampler2D shadowcolor1;
uniform mat4 shadowModelViewInverse;
uniform vec3 cameraPosition;


layout (triangles) in;
in vec3[3]  vertexProj;
in vec3[3]  vertexNormal;
in vec3[3]  vertexTint;
in vec3[3]  midBlock;
in vec2[3]  texcoord;
in vec2[3]  lmcoord;
in vec2[3]  midcoord;
in vec3[3] vertexPosition;
in vec3[3] tangent;
in vec3[3] normal;
in vec3[3] bitangent;
in float[3] isNotOpaque;
flat in int[3]   blockID;

layout (triangle_strip, max_vertices = 7) out;
// Voxel buffer outputs
out vec4  fData0;
out vec4  fData1;
out float isVoxel;
// Shadow buffer outputs
out vec3 tint;
out vec2 textureCoordinates;
out vec2 lightmapCoordinates;
// Texture buffer outputs

#include "/lib/Settings.glsl"
#include "/lib/Voxelization.glsl"

void main() {
    // Normal shadow maps
    // NOTE: You will need to manually clip triangles that are outside the shadow map. This does not currently do that.
    // I have some basic code for that from when I tried CSM but it's inefficient and incomplete.
   	
    for (int i = 0; i < 3; ++i) {
        isVoxel = 0.0;
        gl_Position     = gl_in[i].gl_Position;
        gl_Position.xy  = gl_Position.xy * 0.5 + 0.5;
        // Cull triangles that go outside the shadow map section of the voxel atlas.
        if (gl_in[i].gl_Position.x < -1.0 || gl_in[i].gl_Position.y < -1.0) return;
        tint = vertexTint[i];
        textureCoordinates = texcoord[i];
        lightmapCoordinates = lmcoord[i];
        EmitVertex();
    } EndPrimitive();
	
    // Voxelized geometry
    if (isNotOpaque[0] > 0.5) { return; }

    vec3 triCentroid = (vertexProj[0] + vertexProj[1] + vertexProj[2]) / 3.0;
    vec3 midCentroid = (midBlock[0] + midBlock[1] + midBlock[2]) / 3.0;

    // voxel position in the 2d map
    vec3 voxelSpacePosition = SceneSpaceToVoxelSpace(triCentroid + midCentroid);
    ivec3 voxelIndex = ivec3(floor(voxelSpacePosition));

    float weight = 1.0 - float(blockID[0] == 249 || blockID[0] == 250);
    vec4 p2d = vec4(((GetVoxelStoragePos(voxelIndex) + 0.5) / float(int(MC_SHADOW_QUALITY * shadowMapResolution))) * 2.0 - 1.0, weight * vertexNormal[0].y * -0.25 + 0.5, 1.0);

    if (!IsInVoxelizationVolume(voxelIndex)) { return; }

    vec2 atlasSize = textureSize(texture, 0);

    vec3 width  = tangent[0].xyz * mat3(vertexPosition[0], vertexPosition[1], vertexPosition[2]);
    vec3 height = bitangent[0] * mat3(vertexPosition[0], vertexPosition[1], vertexPosition[2]);

    vec2 faceSize  = vec2(max(width.x, max(width.y, width.z)) - min(width.x, min(width.y, width.z)), max(height.x, max(height.y, height.z)) - min(height.x, min(height.y, height.z)));
        faceSize /= vec2(length(tangent[0].xyz), length(bitangent[0]));

    vec2 minCoord = min(min(texcoord[0], texcoord[1]), texcoord[2]);
    vec2 maxCoord = max(max(texcoord[0], texcoord[1]), texcoord[2]);
    vec2 tileSize = abs(maxCoord - minCoord) / faceSize;
    if(blockID[0] == 249 || blockID[0] == 250) { // Cross blocks
        tileSize = abs(maxCoord - minCoord);
    }
    vec2 tileResolution = round(tileSize * atlasSize);
    ivec2 tileOffset = ivec2(midcoord[0] / tileSize);

        vec3 voxelTint = textureLod(texture, textureCoordinates, 0).rgb * vertexTint[0].rgb;
    

    vec4[2] voxel = vec4[2](vec4(0.0), vec4(0.0));
    SetVoxelTint(voxel, voxelTint);
    SetVoxelId(voxel, blockID[0]);
    SetVoxelTileSize(voxel, tileResolution);
    SetVoxelTileIndex(voxel, tileOffset);

    // Create the primitive

    const vec2[4] offs = vec2[4](vec2(-1,1),vec2(1,1),vec2(1,-1),vec2(-1,-1));
    for (int i = 0; i < 4; ++i) {
        isVoxel = 1.0;
        gl_Position = p2d; fData0 = voxel[0]; fData1 = voxel[1];
        gl_Position.xy += offs[i] / int(MC_SHADOW_QUALITY * shadowMapResolution);
        EmitVertex();
    } EndPrimitive();
}