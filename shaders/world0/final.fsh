#version 430 compatibility
/*

const bool shadowcolor0Clear = false;
const bool colortex8Clear = false;
const bool colortex5Clear = false;
const bool colortex4Clear = false;
const bool colortex3Clear = false;
const bool colortex1Clear = false;
const bool colortex6Clear = false;
const bool colortex9Clear = false;
const bool colortex7Clear = false;
const bool colortex0Clear = false;
const bool colortex2Clear = false;
const bool colortex13Clear = false;

const int colortex0Format = RGB32UI;
const int colortex3Format = RGBA32UI;
const int colortex1Format = RGBA16F;
const int colortex2Format = RGBA16F;
const int colortex4Format = RGBA16F;
const int colortex5Format = RGBA32F;
const int colortex6Format = RGBA32F;
const int colortex7Format = RGBA16F;
const int colortex13Format = RGBA16F;
const int colortex8Format = RGBA16F;
const int colortex9Format = RGB16F;

const int shadowcolor1Format = RG32UI;
const int shadowcolor0Format = RGBA16F;

const vec4 shadowcolor1ClearColor = vec4(0,0,0,0);
const vec4 shadowcolor0ClearColor = vec4(0,0,0,0);

*/

layout (location = 0) out vec3 color;

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex8;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D shadowcolor0;

#include "/lib/Settings.glsl"

uniform vec2 pixelSize;
uniform int frameCounter;
uniform vec2 resolution;
uniform float screenBrightness;

#include "/lib/Random.glsl"


const float sunPathRotation = -40.0f;

vec2 brownConradyDistortion(vec2 uv, float k1)
{
		uv = uv *2. - 1.0;
    // positive values of K1 give barrel distortion, negative give pincushion
    float barrelDistortion1 = k1; // K1 in text books
    float barrelDistortion2 = 0.0; // K2 in text books
    float r2 = uv.x*uv.x + uv.y*uv.y;
    uv *= 1.0 + barrelDistortion1 * r2 + barrelDistortion2 * r2 * r2;


    
    // tangential distortion (due to off center lens elements)
    // is not modeled in this function, but if it was, the terms would go here
    return uv * 0.5 + 0.5;
}

vec2 brownConradyDistortion(in vec2 uv, in float k1, in float k2)
{
    uv = uv * 2.0 - 1.0;	// brown conrady takes [-1:1]

    // positive values of K1 give barrel distortion, negative give pincushion
    float r2 = uv.x*uv.x + uv.y*uv.y;
    uv *= 1.0 + k1 * r2 + k2 * r2 * r2;
    
    // tangential distortion (due to off center lens elements)
    // is not modeled in this function, but if it was, the terms would go here
    
    uv = (uv * .5 + .5);	// restore -> [0:1]
    return uv;
}

vec3 texDistort(sampler2D tex, vec2 tc, vec2 dir, float dist) {
	float lod = 0.;
    return vec3(
        texture(tex, tc + dir * pixelSize * dist, lod).r,
        texture(tex, tc, lod).g,
        texture(tex, tc - dir * pixelSize * dist, lod).b
        );
}

vec3 dither_8bit(vec3 rgb, float pattern) {
    const vec2 mul_add = vec2(1.0, -0.5) / 255.0;
    return rgb + (pattern * mul_add.x + mul_add.y);
}

void main() {
	//color = debug();


#ifdef BarrelDistortion
	float k1 = 0.1;
    vec2 uv = brownConradyDistortion(texcoord, k1);

	color = clamp(uv, vec2(0.0), vec2(1.0)) != uv ? vec3(0.0) : texDistort(colortex7, uv, pow(normalize(vec2(0.5)-uv), vec2(3.))*2., 3.);

	vec2 uv2 = abs(uv*2.0 -1.0);
    vec2 border = 1.-smoothstep(vec2(.95),vec2(1.0),uv2);
    color *= mix(.2, 1.0, border.x * border.y);
#else
        color = texture(colortex7, texcoord).rgb;
#endif
    
    float vignetteRange = 2.;
    float dist = distance(texcoord, vec2(0.5));
    dist = (dist - (2.5 - vignetteRange)) / vignetteRange;
    float mult = smoothstep(1.0, .0, dist);
    

	
	color = dither_8bit(color, fract(fract(frameCounter * (1.0 / GOLDEN_RATIO)) + Bayer16(gl_FragCoord.xy)));

	color *= mult;
	
	//color = Tonemap_ACESFitted2(color);
	//color = tosRGB(color);
}