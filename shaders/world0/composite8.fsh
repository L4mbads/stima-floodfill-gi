
#version 430 compatibility
#include "/lib/Settings.glsl"

/*RENDERTARGETS:7*/
layout (location = 0) out vec3 col;

/*
const bool colortex7MipmapEnabled = true;
*/


in vec2 coord;

uniform sampler2D colortex7;


//https://www.shadertoy.com/view/WtXcRs
vec3 writeBloomTile(in sampler2D tex, in vec2 coord, in float lod) {
    // Transform the tile to "atlas space"
    coord -= 1.0 - exp2(1.0 - lod);
    coord *= exp2(lod);
    
    // Saturate the coord
    if(any(greaterThanEqual(vec2(0.0), coord)))return vec3(0.0);
    if(any(greaterThanEqual(coord, vec2(1.0))))return vec3(0.0);
    
    // Apply threshold
    vec3 color = textureLod(tex, coord, lod).xyz;
    return color;
}


void main() {

    col = vec3(0.0);
    
    for(int i = 1; i <= 7; i++) {
        col += writeBloomTile(colortex7, coord, float(i));
    }

    //col = clamp(col, 0.0, 6500.);

}