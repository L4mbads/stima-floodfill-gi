
#version 430 compatibility
#include "/lib/Settings.glsl"

/*RENDERTARGETS:7*/
layout (location = 0) out vec3 col;

/*
const bool colortex4MipmapEnabled = true;
*/




in vec2 coord;

uniform sampler2D colortex7;
uniform sampler2D colortex4;
uniform float screenBrightness;
uniform vec2 pixelSize;
uniform vec2 resolution;


vec3 texDistort(sampler2D tex, vec2 tc, vec2 dir, float dist, float lod) {

    return vec3(
        texture(tex, tc + dir * pixelSize * dist, lod).r,
        texture(tex, tc, lod).g,
        texture(tex, tc - dir * pixelSize * dist, lod).b
        ) * lod * 0.5;
}

void main() {
    float exposure = (EPS+ texture(colortex4, coord).a);

	col = texture(colortex4, coord).rgb;

       //lensflare
    float aspectRatio = (resolution.x/resolution.y);
    vec2 uv = (vec2(1.0)-coord);
        
    vec2 ghost = (vec2(0.5)-uv) * 0.7 ;

    float w;

    for (int i = 0; i < 3; ++i) {

        vec2 suv = fract(uv + ghost * vec2(i));
        float d = distance(suv, vec2(0.5));
        w = 1.0 - smoothstep(0.0, 0.75, d);

            //w = length(vec2(0.5) - suv) / length(vec2(0.5));
            //w = pow(1.0-w, 1.0);

               //pow(texDistort(colortex4,suv, normalize(ghost), 10., 7.).rgb, vec3(1.5)) * 0.2;
        vec3 s = texDistort(colortex4,suv, normalize(ghost), 8., 7.).rgb * 0.1 * LensFlareStrength;
                 //s = max(s - vec3(8000.), vec3(0.0));
            
        col += s * w  * d;
    }
    vec2 aspectCorrection = vec2(aspectRatio, 1.0);
    
	vec2 halovec = (normalize(-(ghost)*aspectCorrection) * resolution.y/1440. )/aspectCorrection;
	w = length(vec2(0.5)*aspectCorrection - fract(coord + halovec)) / length(vec2(0.5)*aspectCorrection);

    w = pow(1.0-w , 3.0) ;
    col +=  .25* (texDistort(colortex4, (coord + halovec), normalize(ghost), 10., 4.).rgb)* w * min(length(coord * 2.0 - 1.0), 1.0)* LensFlareStrength;
        

}

