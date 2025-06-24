#version 430 compatibility
#include "/lib/Settings.glsl"

/*RENDERTARGETS:7*/
layout (location = 0) out vec4 colortex7Out;


in vec2 texcoord;

uniform sampler2D colortex7;
uniform float screenBrightness;
uniform vec2 pixel;
uniform vec2 resolution;
uniform int hideGUI;
uniform vec2 pixelSize;

/*
vec4 FXAApass(vec2 pos, sampler2D tex, float quality, float threshold, float thresholdMin) {
    vec2 posM = pos;

    vec4 rgbyM = textureLod(tex, posM, 0.0);
    float lumaM = rgbyM.a;

    vec4 luma4A = textureGather(tex, posM, 3);
    vec4 luma4B = textureGatherOffset(tex, posM, ivec2(-1, -1), 3);

    float lumaE = luma4A.z;
    float lumaS = luma4A.x;
    float lumaSE = luma4A.y;
    float lumaNW = luma4B.w;
    float lumaN = luma4B.z;
    float lumaW = luma4B.x;

    float maxSM = max(lumaS, lumaM);
    float minSM = min(lumaS, lumaM);
    float maxESM = max(lumaE, maxSM);
    float minESM = min(lumaE, minSM);
    float maxWN = max(lumaN, lumaW);
    float minWN = min(lumaN, lumaW);
    float rangeMax = max(maxWN, maxESM);
    float rangeMin = min(minWN, minESM);
    float rangeMaxScaled = rangeMax * threshold;
    float range = rangeMax - rangeMin;
    float rangeMaxClamped = max(thresholdMin, rangeMaxScaled);
    if(range < rangeMaxClamped) return rgbyM;

    float lumaNE = textureLodOffset(tex, posM, 0.0, ivec2(1, -1)).a;
    float lumaSW = textureLodOffset(tex, posM, 0.0, ivec2(-1, 1)).a;

    float lumaNS = lumaN + lumaS;
    float lumaWE = lumaW + lumaE;
    float subPixRange = 1.0/range;
    float subPixNSWE = lumaNS + lumaWE;
    float edgeHorz1 = (-2.0 * lumaM) + lumaNS;
    float edgeVert1 = (-2.0 * lumaM) + lumaWE;

    float lumaNESE = lumaNE + lumaSE;
    float lumaNWNE = lumaNW + lumaNE;
    float edgeHorz2 = (-2.0 * lumaE) + lumaNESE;
    float edgeVert2 = (-2.0 * lumaN) + lumaNWNE;

    float lumaNWSW = lumaNW + lumaSW;
    float lumaSWSE = lumaSW + lumaSE;
    float edgeHorz4 = (abs(edgeHorz1) * 2.0) + abs(edgeHorz2);
    float edgeVert4 = (abs(edgeVert1) * 2.0) + abs(edgeVert2);
    float edgeHorz3 = (-2.0 * lumaW) + lumaNWSW;
    float edgeVert3 = (-2.0 * lumaS) + lumaSWSE;
    float edgeHorz = abs(edgeHorz3) + edgeHorz4;
    float edgeVert = abs(edgeVert3) + edgeVert4;

    float subPixNWSWNESE = lumaNWSW + lumaNESE;
    float lengthSign = 1.0/resolution.x;
    bool horzSpan = edgeHorz >= edgeVert;
    float subPixA = subPixNSWE * 2.0 + subPixNWSWNESE;


}
*/

float quality[12] = float[12] (1.0, 1.0, 1.0, 1.0, 1.0, 1.5, 2.0, 2.0, 2.0, 2.0, 4.0, 8.0);

void FXAApass(inout vec4 color, ivec2 texelCoord) {
    float edgeThresholdMin = 0.03125;
    float edgeThresholdMax = 0.0625;
    float subpixelQuality = 0.75;
    int iterations = 12;
    
    vec2 view = pixelSize;
    
    float lumaCenter = luma(texelFetch(colortex7, texelCoord, 0).rgb);
    float lumaDown  = luma(texelFetch(colortex7, texelCoord + ivec2( 0, -1), 0).rgb);
    float lumaUp    = luma(texelFetch(colortex7, texelCoord + ivec2( 0,  1), 0).rgb);
    float lumaLeft  = luma(texelFetch(colortex7, texelCoord + ivec2(-1,  0), 0).rgb);
    float lumaRight = luma(texelFetch(colortex7, texelCoord + ivec2( 1,  0), 0).rgb);
 
    float lumaMin = min(lumaCenter, min(min(lumaDown, lumaUp), min(lumaLeft, lumaRight)));
    float lumaMax = max(lumaCenter, max(max(lumaDown, lumaUp), max(lumaLeft, lumaRight)));
    
    float lumaRange = lumaMax - lumaMin;
    
    if (lumaRange > max(edgeThresholdMin, lumaMax * edgeThresholdMax)) {
        float lumaDownLeft  = luma(texelFetch(colortex7, texelCoord + ivec2(-1, -1), 0).rgb);
        float lumaUpRight   = luma(texelFetch(colortex7, texelCoord + ivec2( 1,  1), 0).rgb);
        float lumaUpLeft    = luma(texelFetch(colortex7, texelCoord + ivec2(-1,  1), 0).rgb);
        float lumaDownRight = luma(texelFetch(colortex7, texelCoord + ivec2( 1, -1), 0).rgb);
     
        float lumaDownUp    = lumaDown + lumaUp;
        float lumaLeftRight = lumaLeft + lumaRight;
        
        float lumaLeftCorners  = lumaDownLeft  + lumaUpLeft;
        float lumaDownCorners  = lumaDownLeft  + lumaDownRight;
        float lumaRightCorners = lumaDownRight + lumaUpRight;
        float lumaUpCorners    = lumaUpRight   + lumaUpLeft;
        
        float edgeHorizontal = abs(-2.0 * lumaLeft   + lumaLeftCorners ) +
                               abs(-2.0 * lumaCenter + lumaDownUp      ) * 2.0 +
                               abs(-2.0 * lumaRight  + lumaRightCorners);
        float edgeVertical   = abs(-2.0 * lumaUp     + lumaUpCorners   ) +
                               abs(-2.0 * lumaCenter + lumaLeftRight   ) * 2.0 +
                               abs(-2.0 * lumaDown   + lumaDownCorners );
        
        bool isHorizontal = (edgeHorizontal >= edgeVertical);       
        
        float luma1 = isHorizontal ? lumaDown : lumaLeft;
        float luma2 = isHorizontal ? lumaUp : lumaRight;
        float gradient1 = luma1 - lumaCenter;
        float gradient2 = luma2 - lumaCenter;
        
        bool is1Steepest = abs(gradient1) >= abs(gradient2);
        float gradientScaled = 0.25 * max(abs(gradient1), abs(gradient2));
        
        float stepLength = isHorizontal ? view.y : view.x;

        float lumaLocalAverage = 0.0;

        if (is1Steepest) {
            stepLength = - stepLength;
            lumaLocalAverage = 0.5 * (luma1 + lumaCenter);
        } else {
            lumaLocalAverage = 0.5 * (luma2 + lumaCenter);
        }
        
        vec2 currentUv = texcoord;
        if (isHorizontal) {
            currentUv.y += stepLength * 0.5;
        } else {
            currentUv.x += stepLength * 0.5;
        }
        
        vec2 offset = isHorizontal ? vec2(view.x, 0.0) : vec2(0.0, view.y);
        
        vec2 uv1 = currentUv - offset;
        vec2 uv2 = currentUv + offset;

        float lumaEnd1 = luma(texture2D(colortex7, uv1).rgb);
        float lumaEnd2 = luma(texture2D(colortex7, uv2).rgb);
        lumaEnd1 -= lumaLocalAverage;
        lumaEnd2 -= lumaLocalAverage;
        
        bool reached1 = abs(lumaEnd1) >= gradientScaled;
        bool reached2 = abs(lumaEnd2) >= gradientScaled;
        bool reachedBoth = reached1 && reached2;
        
        if (!reached1) {
            uv1 -= offset;
        }
        if (!reached2) {
            uv2 += offset;
        }
        
        if (!reachedBoth) {
            for (int i = 2; i < iterations; i++) {
                if (!reached1) {
                    lumaEnd1 = luma(texture2D(colortex7, uv1).rgb);
                    lumaEnd1 = lumaEnd1 - lumaLocalAverage;
                }
                if (!reached2) {
                    lumaEnd2 = luma(texture2D(colortex7, uv2).rgb);
                    lumaEnd2 = lumaEnd2 - lumaLocalAverage;
                }
                
                reached1 = abs(lumaEnd1) >= gradientScaled;
                reached2 = abs(lumaEnd2) >= gradientScaled;
                reachedBoth = reached1 && reached2;

                if (!reached1) {
                    uv1 -= offset * quality[i];
                }
                if (!reached2) {
                    uv2 += offset * quality[i];
                }
                
                if (reachedBoth) break;
            }
        }
        
        float distance1 = isHorizontal ? (texcoord.x - uv1.x) : (texcoord.y - uv1.y);
        float distance2 = isHorizontal ? (uv2.x - texcoord.x) : (uv2.y - texcoord.y);

        bool isDirection1 = distance1 < distance2;
        float distanceFinal = min(distance1, distance2);

        float edgeThickness = (distance1 + distance2);

        float pixelOffset = - distanceFinal / edgeThickness + 0.5;
        
        bool isLumaCenterSmaller = lumaCenter < lumaLocalAverage;

        bool correctVariation = ((isDirection1 ? lumaEnd1 : lumaEnd2) < 0.0) != isLumaCenterSmaller;

        float finalOffset = correctVariation ? pixelOffset : 0.0;
        
        float lumaAverage = (1.0 / 12.0) * (2.0 * (lumaDownUp + lumaLeftRight) + lumaLeftCorners + lumaRightCorners);
        float subPixelOffset1 = clamp(abs(lumaAverage - lumaCenter) / lumaRange, 0.0, 1.0);
        float subPixelOffset2 = (-2.0 * subPixelOffset1 + 3.0) * subPixelOffset1 * subPixelOffset1;
        float subPixelOffsetFinal = subPixelOffset2 * subPixelOffset2 * subpixelQuality;

        finalOffset = max(finalOffset, subPixelOffsetFinal);
        
        // Compute the final UV coordinates.
        vec2 finalUv = texcoord;
        if (isHorizontal) {
            finalUv.y += finalOffset * stepLength;
        } else {
            finalUv.x += finalOffset * stepLength;
        }

        color.rgb = vec3(texture2D(colortex7, finalUv).rgb);
    }

}

void FXAApass2(inout vec4 color, ivec2 texelCoord) {
    float edgeThresholdMin = 0.03125;
    float edgeThresholdMax = 0.0625;
    float subpixelQuality = 0.75;
    int iterations = 12;
    
    vec2 view = pixelSize;
    
    float lumaCenter = texelFetch(colortex7, texelCoord, 0).a;
    float lumaDown  = texelFetch(colortex7, texelCoord + ivec2( 0, -1), 0).a;
    float lumaUp    = texelFetch(colortex7, texelCoord + ivec2( 0,  1), 0).a;
    float lumaLeft  = texelFetch(colortex7, texelCoord + ivec2(-1,  0), 0).a;
    float lumaRight = texelFetch(colortex7, texelCoord + ivec2( 1,  0), 0).a;
 
    float lumaMin = min(lumaCenter, min(min(lumaDown, lumaUp), min(lumaLeft, lumaRight)));
    float lumaMax = max(lumaCenter, max(max(lumaDown, lumaUp), max(lumaLeft, lumaRight)));
    
    float lumaRange = lumaMax - lumaMin;
    
    if (lumaRange > max(edgeThresholdMin, lumaMax * edgeThresholdMax)) {
        float lumaDownLeft  = texelFetch(colortex7, texelCoord + ivec2(-1, -1), 0).a;
        float lumaUpRight   = texelFetch(colortex7, texelCoord + ivec2( 1,  1), 0).a;
        float lumaUpLeft    = texelFetch(colortex7, texelCoord + ivec2(-1,  1), 0).a;
        float lumaDownRight = texelFetch(colortex7, texelCoord + ivec2( 1, -1), 0).a;
     
        float lumaDownUp    = lumaDown + lumaUp;
        float lumaLeftRight = lumaLeft + lumaRight;
        
        float lumaLeftCorners  = lumaDownLeft  + lumaUpLeft;
        float lumaDownCorners  = lumaDownLeft  + lumaDownRight;
        float lumaRightCorners = lumaDownRight + lumaUpRight;
        float lumaUpCorners    = lumaUpRight   + lumaUpLeft;
        
        float edgeHorizontal = abs(-2.0 * lumaLeft   + lumaLeftCorners ) +
                               abs(-2.0 * lumaCenter + lumaDownUp      ) * 2.0 +
                               abs(-2.0 * lumaRight  + lumaRightCorners);
        float edgeVertical   = abs(-2.0 * lumaUp     + lumaUpCorners   ) +
                               abs(-2.0 * lumaCenter + lumaLeftRight   ) * 2.0 +
                               abs(-2.0 * lumaDown   + lumaDownCorners );
        
        bool isHorizontal = (edgeHorizontal >= edgeVertical);       
        
        float luma1 = isHorizontal ? lumaDown : lumaLeft;
        float luma2 = isHorizontal ? lumaUp : lumaRight;
        float gradient1 = luma1 - lumaCenter;
        float gradient2 = luma2 - lumaCenter;
        
        bool is1Steepest = abs(gradient1) >= abs(gradient2);
        float gradientScaled = 0.25 * max(abs(gradient1), abs(gradient2));
        
        float stepLength = isHorizontal ? view.y : view.x;

        float lumaLocalAverage = 0.0;

        if (is1Steepest) {
            stepLength = - stepLength;
            lumaLocalAverage = 0.5 * (luma1 + lumaCenter);
        } else {
            lumaLocalAverage = 0.5 * (luma2 + lumaCenter);
        }
        
        vec2 currentUv = texcoord;
        if (isHorizontal) {
            currentUv.y += stepLength * 0.5;
        } else {
            currentUv.x += stepLength * 0.5;
        }
        
        vec2 offset = isHorizontal ? vec2(view.x, 0.0) : vec2(0.0, view.y);
        
        vec2 uv1 = currentUv - offset;
        vec2 uv2 = currentUv + offset;

        float lumaEnd1 = texture2D(colortex7, uv1).a;
        float lumaEnd2 = texture2D(colortex7, uv2).a;
        lumaEnd1 -= lumaLocalAverage;
        lumaEnd2 -= lumaLocalAverage;
        
        bool reached1 = abs(lumaEnd1) >= gradientScaled;
        bool reached2 = abs(lumaEnd2) >= gradientScaled;
        bool reachedBoth = reached1 && reached2;
        
        if (!reached1) {
            uv1 -= offset;
        }
        if (!reached2) {
            uv2 += offset;
        }
        
        if (!reachedBoth) {
            for (int i = 2; i < iterations; i++) {
                if (!reached1) {
                    lumaEnd1 = texture2D(colortex7, uv1).a;
                    lumaEnd1 = lumaEnd1 - lumaLocalAverage;
                }
                if (!reached2) {
                    lumaEnd2 = texture2D(colortex7, uv2).a;
                    lumaEnd2 = lumaEnd2 - lumaLocalAverage;
                }
                
                reached1 = abs(lumaEnd1) >= gradientScaled;
                reached2 = abs(lumaEnd2) >= gradientScaled;
                reachedBoth = reached1 && reached2;

                if (!reached1) {
                    uv1 -= offset * quality[i];
                }
                if (!reached2) {
                    uv2 += offset * quality[i];
                }
                
                if (reachedBoth) break;
            }
        }
        
        float distance1 = isHorizontal ? (texcoord.x - uv1.x) : (texcoord.y - uv1.y);
        float distance2 = isHorizontal ? (uv2.x - texcoord.x) : (uv2.y - texcoord.y);

        bool isDirection1 = distance1 < distance2;
        float distanceFinal = min(distance1, distance2);

        float edgeThickness = (distance1 + distance2);

        float pixelOffset = - distanceFinal / edgeThickness + 0.5;
        
        bool isLumaCenterSmaller = lumaCenter < lumaLocalAverage;

        bool correctVariation = ((isDirection1 ? lumaEnd1 : lumaEnd2) < 0.0) != isLumaCenterSmaller;

        float finalOffset = correctVariation ? pixelOffset : 0.0;
        
        float lumaAverage = (1.0 / 12.0) * (2.0 * (lumaDownUp + lumaLeftRight) + lumaLeftCorners + lumaRightCorners);
        float subPixelOffset1 = clamp(abs(lumaAverage - lumaCenter) / lumaRange, 0.0, 1.0);
        float subPixelOffset2 = (-2.0 * subPixelOffset1 + 3.0) * subPixelOffset1 * subPixelOffset1;
        float subPixelOffsetFinal = subPixelOffset2 * subPixelOffset2 * subpixelQuality;

        finalOffset = max(finalOffset, subPixelOffsetFinal);
        
        // Compute the final UV coordinates.
        vec2 finalUv = texcoord;
        if (isHorizontal) {
            finalUv.y += finalOffset * stepLength;
        } else {
            finalUv.x += finalOffset * stepLength;
        }

        color.rgb = vec3(texture2D(colortex7, finalUv).rgb);
    }

}


vec2[9] neighbourhoodOffsets = vec2[9](
    vec2(-1.0, -1.0),
    vec2( 0.0, -1.0),
    vec2( 1.0, -1.0),
    vec2(-1.0,  0.0),
    vec2( 0.0,  0.0),
    vec2( 1.0,  0.0),
    vec2(-1.0,  1.0),
    vec2( 0.0,  1.0),
    vec2( 1.0,  1.0)
);


vec3 CASPass(sampler2D tex, vec2 coord) {

    if(hideGUI==1) return texture(tex, coord).rgb;

    const float sharpness = 0.25;

    vec3[9] data;

    for(int i = 0; i < 9; i++) {

        data[i] = texture(tex, coord + neighbourhoodOffsets[i] * pixelSize).rgb;

    }

    vec3 minRGB = min(min(min(data[3], data[4]), min(data[5], data[1])), data[7]);
    vec3 minRGB2 = min(minRGB, min(min(data[0], data[2]), min(data[6], data[8])));
    minRGB += minRGB2;
    
    vec3 maxRGB = max(max(max(data[3], data[4]), max(data[5], data[1])), data[7]);
    vec3 maxRGB2 = max(maxRGB, max(max(data[0], data[2]), max(data[6], data[8])));
    maxRGB += maxRGB2;

    vec3 rcpMRGB = vec3(1.0/max(vec3(EPS), maxRGB));
    vec3 ampRGB = clamp(min(minRGB, vec3(2.0) - maxRGB) * rcpMRGB, vec3(0.0), vec3(1.0));

    ampRGB = inversesqrt(ampRGB);

    float peak = 8.0 - 3.0 * sharpness;
    vec3 wRGB = -(vec3(1.0/max(vec3(EPS), ampRGB * peak)));

    vec3 rcpWeightRGB = vec3(1.0/ (1.0 + 4.0 * wRGB));

    vec3 window = (data[1] + data[3]) + (data[5] + data[7]);

    return clamp((window * wRGB + data[4]), vec3(0.0), vec3(1.0));

}


void main() {


    colortex7Out =  texture(colortex7, texcoord);




    vec3 albedoCurrent1 = texture2D(colortex7, texcoord + vec2(pixelSize.x,pixelSize.y)*0.5).rgb;
    vec3 albedoCurrent2 = texture2D(colortex7, texcoord + vec2(pixelSize.x,-pixelSize.y)*0.5).rgb;
    vec3 albedoCurrent3 = texture2D(colortex7, texcoord + vec2(-pixelSize.x,-pixelSize.y)*0.5).rgb;
    vec3 albedoCurrent4 = texture2D(colortex7, texcoord + vec2(-pixelSize.x,pixelSize.y)*0.5).rgb;
    const float SHARPENING = 3.;

    vec3 m1 = -0.5/3.5*colortex7Out.rgb + albedoCurrent1/3.5 + albedoCurrent2/3.5 + albedoCurrent3/3.5 + albedoCurrent4/3.5;
    vec3 std = abs(colortex7Out.rgb - m1) + abs(albedoCurrent1 - m1) + abs(albedoCurrent2 - m1) +
     abs(albedoCurrent3 - m1) + abs(albedoCurrent3 - m1) + abs(albedoCurrent4 - m1);
    float contrast = 1.0 - luma(std)/5.0;
    colortex7Out.rgb = colortex7Out.rgb*(1.0+(SHARPENING)*contrast) - (SHARPENING)/(1.0-0.5/3.5)*contrast*(m1 - 0.5/3.5*colortex7Out.rgb);

    //FXAApass2(colortex7Out, ivec2(gl_FragCoord.xy));

    //colortex7Out.rgb = Tonemap_ACESFitted2(colortex7Out.rgb);

}