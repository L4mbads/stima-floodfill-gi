
#version 430 compatibility
#include "/lib/Settings.glsl"

/*RENDERTARGETS:7*/
layout (location = 0) out vec3 col;


in vec2 coord;

uniform sampler2D colortex7;

const float[9] kernel2 = float[9](
    0.0625,
    0.125,
    0.0625,
    0.125,
    0.25,
    0.125,
    0.0625,
    0.125,
    0.0625
);

vec3 textureBlur(in sampler2D tex, in vec2 coord) {
        const int size = 9;
    vec2 texelSize = 1.0 / vec2(textureSize(tex, 0));
    
    float lod = ceil(-log2(1.0 - coord.x));
    
    vec2 tileCoord = coord;
    tileCoord -= 1.0 - exp2(1.0 - lod);
    tileCoord *= exp2(lod);
    
    // Saturate the coord
    if(any(greaterThanEqual(vec2(0.0), tileCoord)))return vec3(0.0);
    if(any(greaterThanEqual(tileCoord, vec2(1.0))))return vec3(0.0);
    
    float maxLength = length(vec2(size));
    
    vec4 color = vec4(0.0);

    for(int i = -size; i <= size; i++) {
        vec2 offset = vec2(0, i);
        float weight = 1.0 - smoothstep(0.0, 1.0, sqrt(length(offset) / maxLength));

        vec2 sampleCoord = coord + texelSize * offset;

        color.xyz += texture(tex, sampleCoord).xyz * weight;
        color.w   += weight;
    }
    return color.xyz / color.w;
}


void main() {

    col = textureBlur(colortex7, coord);


}