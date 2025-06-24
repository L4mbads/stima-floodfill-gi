
#version 430 compatibility
#include "/lib/Settings.glsl"

/*RENDERTARGETS:4*/
layout (location = 0) out vec4 colortex4Out;




in vec2 texcoord;

uniform sampler2D colortex7;
uniform sampler2D colortex4;
uniform sampler2D depthtex1;
uniform float screenBrightness;
uniform vec2 pixelSize;
uniform vec2 resolution;
uniform sampler2D shadowcolor0;

#include "/lib/Projection.glsl"

vec2[8] TAAneighbourhoodOffsets = vec2[8](
    vec2(-1.0, -1.0),
    vec2( 0.0, -1.0),
    vec2( 1.0, -1.0),
    vec2(-1.0,  0.0),
    vec2( 1.0,  0.0),
    vec2(-1.0,  1.0),
    vec2( 0.0,  1.0),
    vec2( 1.0,  1.0)
);

float minDepth(sampler2D tex, vec2 coord) {
    float minD = texture(tex, coord).r;
        for(int i = 0; i < 8; i++) {
        vec2 offset = TAAneighbourhoodOffsets[i] * pixelSize;
        float temp = texture(tex, coord + offset).r;

        minD = min(temp, minD);
    }
    return minD;

}

vec4 sampleTextureCatmullRom4Samples(sampler2D tex, vec2 uv, vec2 texSize, out float weight)
{
    // Based on the standard Catmull-Rom spline: w1*C1+w2*C2+w3*C3+w4*C4, where
    // w1 = ((-0.5*f + 1.0)*f - 0.5)*f, w2 = (1.5*f - 2.5)*f*f + 1.0,
    // w3 = ((-1.5*f + 2.0)*f + 0.5)*f and w4 = (0.5*f - 0.5)*f*f with f as the
    // normalized interpolation position between C2 (at f=0) and C3 (at f=1).

    // half_f is a sort of sub-pixelquad fraction, -1 <= half_f < 1.
    vec2 half_f     = 2.0 * fract(0.5 * uv * texSize - 0.25) - 1.0;

    // f is the regular sub-pixel fraction, 0 <= f < 1. This is equivalent to
    // fract(uv * texSize - 0.5), but based on half_f to prevent rounding issues.
    vec2 f          = fract(half_f);

    vec2 s1         = ( 0.5 * f - 0.5) * f;            // = w1 / (1 - f)
    vec2 s12        = (-2.0 * f + 1.5) * f + 1.0;      // = (w2 - w1) / (1 - f)
    vec2 s34        = ( 2.0 * f - 2.5) * f - 0.5;      // = (w4 - w3) / f

    // positions is equivalent to: (floor(uv * texSize - 0.5).xyxy + 0.5 +
    // vec4(-1.0 + w2 / (w2 - w1), 1.0 + w4 / (w4 - w3))) / texSize.xyxy.
    vec4 positions  = vec4((-f * s12 + s1      ) / (texSize * s12) + uv,
                           (-f * s34 + s1 + s34) / (texSize * s34) + uv);

    // Determine if the output needs to be sign-flipped. Equivalent to .x*.y of
    // (1.0 - 2.0 * floor(t - 2.0 * floor(0.5 * t))), where t is uv * texSize - 0.5.
    float sign_flip = half_f.x * half_f.y > 0.0 ? 1.0 : -1.0;

    vec4 w          = vec4(-f * s12 + s12, s34 * f); // = (w2 - w1, w4 - w3)
    vec4 weights    = vec4(w.xz * (w.y * sign_flip), w.xz * (w.w * sign_flip));

    weight = max4(weights.x,weights.y,  weights.z,weights.w);

    return texture(tex, positions.xy) * weights.x +
           texture(tex, positions.zy) * weights.y +
           texture(tex, positions.xw) * weights.z +
           texture(tex, positions.zw) * weights.w;
}

vec3 FastCatmulRom(sampler2D colorTex, vec2 texcoord, vec4 rtMetrics, float sharpenAmount, out float weight)
{
    vec2 position = rtMetrics.zw * texcoord;
    vec2 centerPosition = floor(position - 0.5) + 0.5;
    vec2 f = position - centerPosition;
    vec2 f2 = f * f;
    vec2 f3 = f * f2;

    float c = sharpenAmount;
    vec2 w0 =        -c  * f3 +  2.0 * c         * f2 - c * f;
    vec2 w1 =  (2.0 - c) * f3 - (3.0 - c)        * f2         + 1.0;
    vec2 w2 = -(2.0 - c) * f3 + (3.0 -  2.0 * c) * f2 + c * f;
    vec2 w3 =         c  * f3 -                c * f2;

    vec2 w12 = w1 + w2;
    vec2 tc12 = rtMetrics.xy * (centerPosition + w2 / w12);
    vec3 centerColor = texture2D(colorTex, vec2(tc12.x, tc12.y)).rgb;

    weight = max4(w0.x, w1.x, w2.x, w3.x) * max4(w0.y, w1.y, w2.y, w3.y);

    vec2 tc0 = rtMetrics.xy * (centerPosition - 1.0);
    vec2 tc3 = rtMetrics.xy * (centerPosition + 2.0);
    vec4 color = vec4(texture2D(colorTex, vec2(tc12.x, tc0.y )).rgb, 1.0) * (w12.x * w0.y ) +
                   vec4(texture2D(colorTex, vec2(tc0.x,  tc12.y)).rgb, 1.0) * (w0.x  * w12.y) +
                   vec4(centerColor,                                      1.0) * (w12.x * w12.y) +
                   vec4(texture2D(colorTex, vec2(tc3.x,  tc12.y)).rgb, 1.0) * (w3.x  * w12.y) +
                   vec4(texture2D(colorTex, vec2(tc12.x, tc3.y )).rgb, 1.0) * (w12.x * w3.y );
    return color.rgb/color.a;

}

vec3 clipToAABB(in vec3 cOld, in vec3 cNew, in vec3 center, in vec3 halfSize)
{
    vec3 r = cOld - cNew;
    vec3 m = (center + halfSize) - cNew;
    vec3 n = (center - halfSize) - cNew;
    
    if (r.x > m.x + EPS)
        r *= (m.x / r.x);
    if (r.y > m.y + EPS)
        r *= (m.y / r.y);
    if (r.z > m.z + EPS)
        r *= (m.z / r.z);

    if (r.x < n.x - EPS)
        r *= (n.x / r.x);
    if (r.y < n.y - EPS)
        r *= (n.y / r.y);
    if (r.z < n.z - EPS)
        r *= (n.z / r.z);

    return cNew + r;
}
//FIX THIS SHIT
vec3 TAAneighbourhoodClamp(vec3 color, sampler2D tex, sampler2D prevTex, vec2 coord, vec2 prevCoord, float depth, out float weight, inout float edge) {
    
    vec3 minCol = sRGBtoYCoCg * color;
    vec3 maxCol = sRGBtoYCoCg * color;

    //vec3 prevColor = sampleTextureCatmullRom4Samples(prevTex, coord, pixelSize, weight).rgb;
    vec3 prevColor = sRGBtoYCoCg *FastCatmulRom(prevTex, prevCoord, vec4(pixelSize, resolution), 0.6, weight).rgb;
    //vec3 prevColor = texture(prevTex, coord).rgb;
    if(prevColor == vec3(0.0)) return color;

    for(int i = 0; i < 8; i++) {
        vec2 offset = TAAneighbourhoodOffsets[i] * pixelSize;

        vec2 uv = coord + offset;

        if(clamp(uv, vec2(0.0), vec2(1.0)) != uv) continue;

        float depthCheck = toViewSpaceDepth(texture(depthtex1, uv, 0).a);
        if (abs(depthCheck - depth) > 0.09) {
            edge = 20.;
        }

        
        vec3 temp = sRGBtoYCoCg * texture(tex, coord + offset).rgb;

        minCol = min(temp, minCol);
        maxCol = max(temp, maxCol);
    }

    return YCoCgtosRGB * clamp( prevColor, minCol,  maxCol);
}

void TAATonemap(inout vec3 color) {
    float lum = 1.0 / (1.0 + luma(color));
    color *= lum;
}

void TAAinvTonemap(inout vec3 color) {
    float lum = 1.0 / (1.0 - luma(color));
    color *= lum;
}

vec3 TAAresolve(vec3 color, sampler2D tex, sampler2D prevTex, vec2 coord, vec2 prevCoord, float depth, float a) {



    vec2 velocity = (texcoord - prevCoord) * resolution;

    //velocity -= (TAAoffsets[frameCounter%8]+TAAoffsets[(frameCounter-1)%8] )  * pixelSize;
    float confidence;
    float edge = 0.0;
    vec3 prevColor = max(TAAneighbourhoodClamp(color, tex, prevTex, coord, prevCoord, toViewSpaceDepth(depth), confidence, edge), vec3(0.0));
    //vec3 prevColor = texture(prevTex, prevCoord).rgb;
    float weight = exp(-length(velocity) ) * 0.6 + 0.3;
    
    float blendMinimum = 0.3;
    float blendVariable = 0.25;
    float blendConstant = 0.65;
    float velocityFactor = dot(velocity, velocity) * 10.0;
    float blendFactor = max( (exp(-velocityFactor) * blendVariable + blendConstant - length(cameraPosition - previousCameraPosition) * edge), blendMinimum);
    
    TAATonemap(color);
    TAATonemap(prevColor);




    vec3 result = mix(color,  prevColor,  clamp(confidence* max(0.1,float(clamp(prevCoord, vec2(0.0), vec2(1.0)) == prevCoord)), 0.3, 0.98));
    //vec3 result = current.rgb * 0.1 * current.a + previous.rgb * previous.a * 0.9;

    TAAinvTonemap(result);

    return result;

}



void main() {




        colortex4Out.rgb = texture(colortex7, texcoord*TAAUres).rgb;
        colortex4Out.a = texture(colortex4, texcoord).a;
        float depth = texture(depthtex1, texcoord).r;
        vec2 prevCoord = toPrevScreenPos(texcoord, depth);

    #ifdef TemporalAA
        colortex4Out.rgb = TAAresolve(colortex4Out.rgb, colortex7, colortex4, texcoord*TAAUres, prevCoord, (depth), 1.0);
    #endif
        
}

