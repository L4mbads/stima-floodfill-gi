#version 430 compatibility


uniform usampler2D shadowcolor1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex1;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D colortex2;
uniform sampler2D colortex13;
uniform int frameCounter;
uniform vec2 resolution;
uniform vec3 sunVector;
uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform int hideGUI;

#include "/lib/Settings.glsl"
#include "/lib/Random.glsl"
#include "/lib/Encoding.glsl"
#include "/lib/Atmosphere.glsl"
#include "/lib/Projection.glsl"
#include "/lib/Voxelization.glsl"
#include "/lib/Voxel_Intersect.glsl"



/* RENDERTARGETS:2 */

layout (location = 0) out vec4 floodFillData;

in vec2 texcoord;


const ivec3[6] offset = ivec3[6](
        ivec3(-1.0, 0.0, 0.0),
        ivec3(1.0, 0.0, 0.0),
        ivec3(0.0, 1.0, 0.0),
        ivec3(0.0, -1.0, 0.0),
        ivec3(0.0, 0.0, 1.0),
        ivec3(0.0, 0.0, -1.0)

    );



bool hitNoncubic(int id, ivec3 offset) {
/*
        +x
        e

 -z n       s +z

        w
        -x

*/

id = (id >= 55 && id <= 63) ? 100 : id;//LOL IM LAZY

    switch(id) {

        case 5: {

            return (offset.y == -1);
        }

         case 18: {

            return (offset.y == 1);
        }

        case 6: {

            return any(equal(offset, ivec3(10, -1, -1)));
        }

        case 7: {

            return any(equal(offset, ivec3(10, -1, 1)));
        }

        case 8: {

            return any(equal(offset, ivec3(1, -1, 10)));
        }

        case 9: {

            return any(equal(offset, ivec3(-1, -1, 10)));
        }

        case 10: {

            return any(equal(offset, ivec3(-1)));
        }

        case 11: {

            return any(equal(offset, ivec3(1, -1, -1)));
        }

        case 12: {

            return any(equal(offset, ivec3(-1, -1, 1)));
        }

        case 13: {

            return any(equal(offset, ivec3(1, -1, 1)));
        }

        case 14: {

            return (offset.y == -1);
        }

        case 15: {

            return (offset.y == -1);
        }

        case 16: {

            return (offset.y == -1);
        }

        case 17: {

            return (offset.y == -1);
        }

        case 19: {

            return any(equal(offset, ivec3(10, 1, -1)));
        }

        case 20: {

            return any(equal(offset, ivec3(10, 1, 1)));
        }

        case 21: {

            return any(equal(offset, ivec3(1, 1, 10)));
        }

        case 22: {

            return any(equal(offset, ivec3(-1, 1, 10)));
        }

        case 23: {

            return any(equal(offset, ivec3(-1, 1, -1)));
        }

        case 24: {

            return any(equal(offset, ivec3(1, 1, -1)));
        }

        case 25: {

            return any(equal(offset, ivec3(-1, 1, 1)));
        }

        case 26: {

            return any(equal(offset, ivec3(1, 1, 1)));
        }

        case 27: {

            return (offset.y == 1);
        }

        case 28: {

            return (offset.y == 1);
        }

        case 29: {

            return (offset.y == 1);
        }

        case 30: {

            return (offset.y == 1);
        }

        case 100: {
            return (offset.y == -1);
        }

        default: {

            return false;
        }
    }




}

const float falloff = 2.43902;

const vec3 sun = (vec3(3000.) * (vec3(1.0, 0.89, 0.85)*sRGBtoAP1 ));
const vec3 sky = vec3(47.*100.) * getValFromSkyLUT(normalize(vec3(0.0, 1.0, 0.0)),  sunVector);
const vec3 sunTransmittance = getValFromTLUT(colortex13, resolution, vec3(0.0, groundRadiusMM + 0.000063, 0.0), sunVector);


void main() {

    ivec2 uv = ivec2(gl_FragCoord.xy);

    //if(uv.x >=  (shadowMapResolution/2)){floodFillData=texelFetch(shadowcolor0, uv, 0); return;}

    ivec3 voxelPos = StoragePosToVoxelSpace(uv);
    ivec3 prevVoxelPos = ivec3(voxelPos + floor(cameraPosition) - floor(previousCameraPosition));

    if(frameCounter%3!=0) {floodFillData = (texelFetch(colortex2,  GetPreviousVoxelStoragePos(prevVoxelPos, previousCameraPosition.y), 0)); return;}


    vec4 data = unpackUnorm4x8(texelFetch(shadowcolor1, uv, 0).x);

    int id = int(0.5 + 255.0 * data.a);

    bool translucent = id == 201 || id == 200;
    bool emissive = (id >= 67 && id <= 118);
    bool noncubic = (id >= 4 && id <= 66)||(id >= 249 && id <= 252);


   //vec4 sun = texelFetch(shadowcolor0, uv, 0);

    floodFillData.rgb = ((data.rgb)* sRGBtoAP1 * float(emissive || translucent) * ((id >= 69 && id <= 109) ? 400. : 4000.)) ;
    //floodFillData += data.rgb*float(sunVis) * sun * sunTransmittance * 2.;

    if((data.a) > 0.0 && !translucent && !noncubic) return;

    bool upVis = !(RaytraceVoxelShadows(voxelPos, ivec3(floor(voxelPos+vec3(0.0, 0.05, 0.0))),  mat3(gbufferModelViewInverse)*upPosition, true, 20));

    #ifdef ShadowMapSunFloodFill
        vec3 sunVisibility = calculateShadow(shadowtex1, feetToShadowScreen(VoxelSpaceToSceneSpace(voxelPos+vec3(0.0, 0.05, 0.0))), 0.0004);
    #else
        vec3 sunVisibility = vec3(RaytraceVoxelShadows2(prevVoxelPos, ivec3(floor(prevVoxelPos+vec3(0.05))),  sunVector, false, 40));
    #endif



    ivec2 puv = GetPreviousVoxelStoragePos(prevVoxelPos, previousCameraPosition.y);

    vec3 samples = vec3(0.0);

    //balint floodfill method
    for(int i = 0; i < 6; ++i) {

        if(hitNoncubic(id, offset[i])) continue;

        ivec2 previousSampleVoxelUV = GetPreviousVoxelStoragePos(prevVoxelPos+offset[i], previousCameraPosition.y);
        ivec2 sampleVoxelUV = GetVoxelStoragePos(voxelPos+offset[i]);

        vec4 sampleVoxel = unpackUnorm4x8(texelFetch(shadowcolor1, sampleVoxelUV, 0).x);

        sampleVoxel.rgb /= PI;

        int sampleVoxelID = int(0.5 + 255.0 * sampleVoxel.a);

        bool nonCubic = (sampleVoxelID >= 4 && sampleVoxelID <= 66)||(sampleVoxelID >= 249 && sampleVoxelID <= 252);
        bool translucent = (sampleVoxelID == 201);

        vec3 previousSampleVoxel = (texelFetch(colortex2, previousSampleVoxelUV, 0).rgb);

        vec3 sunContribution = sunVisibility * (length(sampleVoxel.rgb) <= 0.0 ? vec3(0.0) : sampleVoxel.rgb) * sun
                             * float(max0(dot(normalize(-offset[i]), sunVector))) * sunTransmittance;
        vec3 skyContribution = float(upVis) * (length(sampleVoxel.rgb) <= 0.0 ? vec3(1.0) : sampleVoxel.rgb) * sky;

        vec3 visibility = mix(vec3(1.0), sampleVoxel.rgb, float(translucent)) * float(!hitNoncubic(sampleVoxelID, -offset[i]));
        vec3 sampleVoxelContribution = previousSampleVoxel * visibility;

        samples += pow(sunContribution + skyContribution + sampleVoxelContribution, vec3(2.2));
    }
    floodFillData.rgb =  (pow(samples, vec3(1.0/2.2)) / 6.0) * falloff;

}