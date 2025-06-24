#version 430 compatibility
#include "/lib/Settings.glsl"

/*RENDERTARGETS:7,4*/
layout (location = 0) out vec4 colortex7Out;
layout (location = 1) out vec4 colortex4Out;

in vec2 coord;

uniform sampler2D colortex7;
uniform sampler2D colortex4;
uniform float screenBrightness;
uniform vec2 pixel;
uniform vec2 resolution;
uniform int hideGUI;

/*
const bool colortex7MipmapEnabled = true;
*/

vec3 readBloomTile(in sampler2D tex, in vec2 coord, in float lod) {
    // Calculate those values to compute both tile transform and sampling bounds
    float offset = 1.0 - exp2(1.0 - lod);
    float width = exp2(-lod);
    
    // Inverse atlas transform
    coord *= width; // /= exp2(lod)
    coord += offset;
    
    // The single-texel margin is needed to account for linear atlas filtering issues
    // Can be removed if set to nearest, but the bloom will look blocky and awful
    // The bounding without margin is not needed at all, so both shall be removed together
    vec2 bounds = vec2(offset, offset + width);
    vec2 texelSize = 1.0 / vec2(textureSize(tex, 0));
    float margin = max(texelSize.x, texelSize.y);
    bounds.x += margin;
    bounds.y -= margin;
    coord = clamp(coord, bounds.x, bounds.y);
    
    return texture(tex, coord, lod).xyz;
}

vec3 getBloom(in sampler2D tex, in vec2 coord) {
    float weight = 0.25;
    const float bloomFalloff = 1.3;
        
    vec4 color = vec4(0.0);
    for(int i = 1; i <= 7; i++) {
        color.xyz += readBloomTile(tex, coord, float(i))* weight ;
        //color.xyz = mix(color.rgb, readBloomTile(tex, coord, float(i)), 0.9)* weight ;
        color.w   += 1.0;
        
        weight *= bloomFalloff;
    }
    return color.xyz / color.w;
}




void main() {
    //float exposure = (EPS+ texture(colortex4, coord).a);

    colortex4Out = texture(colortex4, coord);

    float exposure;

    if(ExposureMode < 2) {

        float avgL = luma(textureLod(colortex7, vec2(0.5*TAAUres), ceil(log2(max(resolution.x, resolution.y)))).rgb);
        float EV100 = log2(avgL * 100./55.);

        float prevExposure = colortex4Out.a;

        exposure = clamp(2.2 * exp2(EV100), 10., 800.);

        if(ExposureMode == 1) exposure /= (EPS+screenBrightness)*50.;

        exposure = mix(exposure, prevExposure, 0.9);

    } else {

        exposure = pow2(screenBrightness)*1000.;
    }

    colortex4Out.a = exposure;

    vec3 bloom = getBloom(colortex7, coord)*0.25*BloomStrength; 

    vec3 col = texture(colortex4, coord).rgb;

    col = (mix(col, bloom, luma(bloom/(1.0+bloom))/exposure))/exposure;//YOO applying exposure again seems to work

    colortex7Out = vec4(Tonemap_ACESFitted2(col), (luma(col)));
    //col = col - col2;
    //col /=  ;


}