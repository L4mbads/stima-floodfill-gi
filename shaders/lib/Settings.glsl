#extension GL_EXT_gpu_shader4 : require
#extension GL_ARB_shader_texture_lod : require
#extension GL_ARB_texture_gather : require

#define VoxelizationFix
#define VoxelLowerBound 48 // How many blocks under the player to voxelize. The voxelization can store a max of 128 blocks, so the amount of blocks above the player is calculated as (127 - amount of blocks under the player) [128 96 80 64 48 32 16 0]
#define VoxelUpperBound (127 - VoxelLowerBound)

#define TemporalFilter
//#define TemporalResampling
#define SpatialFilter
#define IrradianceCaching
//#define DebugIC
//#define WhiteWorld
//#define ShadowMapSunFloodFill

#define DirectLight
#define IndirectLight
#define Specular
#define Emission
#define Fog

#define RoughSpecular
#define CosineSampling

#define TemporalAA

#define ExposureMode 0 // hello [0 1 2]

#define SpecularSamples 2 //[1 2 3 4 5 6 7 8 9 10]
#define DiffuseSamples 1 //[1 2 3 4 5 6 7 8 9 10]
#define RayBounce 1 //[1 2 3 4]

#define SSSIntensity 1 //[1 2 3 4 5]
#define SSSFalloff 3 //[1 2 3 4 5]

#define FireflyRejectionStrength 2 //[1 2 3 4 5]

#define BlockLightShadowSharpness 3 //[1 2 3 4 5]
#define ShadowSamples 20 //[10 20 30 40 50 60]

#define LensFlareStrength 2.0 //[1. 2. 3. 4. 5. 6. 7. 8. 9. 10.]
#define BloomStrength 1.0 //[0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]

//constant

const int   shadowMapResolution     = 4096; // [2048 4096 8192 12288 16384]

    #define PI 3.141592
    #define invPI 0.31831
    #define TAU 6.283185
    #define GOLDEN_RATIO 1.618034
    #define EPS 1.e-9


const vec2[8] TAAoffsets =  vec2[8](vec2(1./8.,-3./8.),
                            vec2(-1.,3.)/8.,
                            vec2(5.0,1.)/8.,
                            vec2(-3,-5.)/8.,
                            vec2(-5.,5.)/8.,
                            vec2(-7.,-1.)/8.,
                            vec2(3,7.)/8.,
                            vec2(7.,-7.)/8.);

#define UpscalingRes 0.5 // [0.5 0.6 0.7 0.75 0.8 0.9 1.0]

const vec2 TAAUres = vec2(UpscalingRes);

//=====================================================================

bool IsEmissiveId(int id) { return (id >= 67 && id <= 129); }

bool IsSphericalEmissiveId(int id) { return (id >= 90 && id <= 109); }

bool IsStair(int id) { return (id != 18 && id >= 6 && id <= 30); }

int GetStairState(int id) { return id - 6 - (13 * int(id > 18)); }

//=====================================================================

#define clamp01(x) clamp(x, 0.0, 1.0)
#define clamp05(x) clamp(x, 0.0, 5.0)
#define clamp010(x) clamp(x, 0.0, 10.0)
#define clamp0100(x) clamp(x, 0.0, 100.0)

#define max0(x) max(x, 0.0)
#define max1(x) max(x, 1.0)
#define min0(x) min(x, 0.0)
#define min1(x) min(x, 1.0)

#define max3(x,y,z)       max(x,max(y,z))
#define max4(x,y,z,w)     max(x,max(y,max(z,w)))
#define max5(a,b,c,d,e)   max4(a,b,c,max(d,e))
#define max6(a,b,c,d,e,f) max5(a,b,c,d,max(e,f))

#define min3(a,b,c)       min(min(a,b),c)
#define min4(a,b,c,d)     min(min3(a,b,c),d)
#define min5(a,b,c,d,e)   min(min4(a,b,c,d),e)
#define min6(a,b,c,d,e,f) min(min5(a,b,c,d,e),f)

float maxof(vec2 x) { return max(x.x, x.y); }
float maxof(vec3 x) { return max3(x.x, x.y, x.z); }
float minof(vec2 x) { return min(x.x, x.y); }
float minof(vec3 x) { return min3(x.x, x.y, x.z); }

float pow2(float x) { return x*x; }

float linearstep(float e0, float e1, float x) {
	return clamp((x - e0) / (e1 - e0), 0.0, 1.0);
}

vec3 clampNormal(const vec3 n, const vec3 v) {
    float NoV = clamp(dot(n, -v), 0.0, 1.0);
    return normalize(NoV * v + n);
}

//=====================================================================

// Converts a color from linear light gamma to sRGB gamma
vec3 tosRGB(vec3 linearRGB)
{
    bvec3 cutoff = lessThan(linearRGB, vec3(0.0031308));
    vec3 higher = vec3(1.055)*pow(linearRGB, vec3(1.0/2.4)) - vec3(0.055);
    vec3 lower = linearRGB * vec3(12.92);

    return mix(higher, lower, cutoff);
}

// Converts a color from sRGB gamma to linear light gamma
vec3 toLinear(vec3 sRGB)
{
    bvec3 cutoff = lessThan(sRGB, vec3(0.04045));
    vec3 higher = pow((sRGB + vec3(0.055))/vec3(1.055), vec3(2.4));
    vec3 lower = sRGB/vec3(12.92);

    return mix(higher, lower, cutoff);
}

float luma(vec3 color) {
   return dot(color,vec3(0.299, 0.587, 0.114));
}

const mat3 sRGBtoYCoCg = mat3(0.25, 0.5, -0.25, 0.5, 0.0, 0.5, 0.25, -0.5, -0.25);

const mat3 YCoCgtosRGB = mat3(1.0, 1.0, 1.0, 1.0, 0.0, -1.0, -1.0, 1.0, -1.0);


// ACEScg transforms by TinyTexel
// License: CC0 (https://creativecommons.org/publicdomain/zero/1.0/)

#define If(cond, resT, resF) mix(resF, resT, cond)

float sRGB_InvEOTF(float c)
{
    return c > 0.0031308 ? pow(c, 1.0/2.4) * 1.055 - 0.055 : c * 12.92;
}

float sRGB_EOTF(float c)
{
    return c > 0.04045 ? pow(c / 1.055 + 0.055/1.055, 2.4) : c / 12.92;
}

vec3 sRGB_InvEOTF(vec3 rgb)
{
    return If(greaterThan(rgb, vec3(0.0031308)), pow(rgb, vec3(1.0/2.4)) * 1.055 - 0.055, rgb * 12.92);
}

vec3 sRGB_EOTF(vec3 rgb)
{
    return If(greaterThan(rgb, vec3(0.04045)), pow(rgb / 1.055 + 0.055/1.055, vec3(2.4)), rgb / 12.92);
}


float ACEScc_from_Linear(float lin) 
{    
    if (lin <= 0.0) 
        return -0.3584474886;
    
    if (lin < exp2(-15.0))
        return log2(exp2(-16.0) + lin * 0.5) / 17.52 + (9.72/17.52);
    
    return log2(lin) / 17.52 + (9.72/17.52);
}

vec3 ACEScc_from_Linear(vec3 lin) 
{
    return vec3(ACEScc_from_Linear(lin.r),
                ACEScc_from_Linear(lin.g),
                ACEScc_from_Linear(lin.b));
}


float Linear_from_ACEScc(float cc) 
{
    if (cc < -0.3013698630)
        return exp2(cc * 17.52 - 9.72)*2.0 - exp2(-16.0)*2.0;
    
    return exp2(cc * 17.52 - 9.72);
}

vec3 Linear_from_ACEScc(vec3 cc) 
{
    return vec3(Linear_from_ACEScc(cc.r),
                Linear_from_ACEScc(cc.g),
                Linear_from_ACEScc(cc.b));
}


float ACEScct_from_Linear(float lin)
{
    if(lin > 0.0078125)
        return log2(lin) / 17.52 + (9.72/17.52);
    
    return lin * 10.5402377416545 + 0.0729055341958355;
}

vec3 ACEScct_from_Linear(vec3 lin) 
{
    return vec3(ACEScct_from_Linear(lin.r),
                ACEScct_from_Linear(lin.g),
                ACEScct_from_Linear(lin.b));
}


float Linear_from_ACEScct(float cct)
{
    if(cct > 0.155251141552511)
        return exp2(cct * 17.52 - 9.72);
    
    return cct / 10.5402377416545 - (0.0729055341958355/10.5402377416545);
}

vec3 Linear_from_ACEScct(vec3 cct) 
{
    return vec3(Linear_from_ACEScct(cct.r),
                Linear_from_ACEScct(cct.g),
                Linear_from_ACEScct(cct.b));
}



// ACES fit by Stephen Hill (@self_shadow)
// https://github.com/TheRealMJP/BakingLab/blob/master/BakingLab/ACES.hlsl 

// sRGB => XYZ => D65_2_D60 => AP1
const mat3 sRGBtoAP1 = mat3
(
    0.613097, 0.339523, 0.047379,
    0.070194, 0.916354, 0.013452,
    0.020616, 0.109570, 0.869815
);

const mat3 AP1toSRGB = mat3
(
     1.704859, -0.621715, -0.083299,
    -0.130078,  1.140734, -0.010560,
    -0.023964, -0.128975,  1.153013
);

// AP1 => RRT_SAT
const mat3 RRT_SAT = mat3
(
    0.970889, 0.026963, 0.002148,
    0.010889, 0.986963, 0.002148,
    0.010889, 0.026963, 0.962148
);


// sRGB => XYZ => D65_2_D60 => AP1 => RRT_SAT
const mat3 ACESInputMat = mat3
(
    0.59719, 0.35458, 0.04823,
    0.07600, 0.90834, 0.01566,
    0.02840, 0.13383, 0.83777
);

// ODT_SAT => XYZ => D60_2_D65 => sRGB
const mat3 ACESOutputMat = mat3
(
     1.60475, -0.53108, -0.07367,
    -0.10208,  1.10813, -0.00605,
    -0.00327, -0.07276,  1.07602
);

vec3 RRTAndODTFit(vec3 x)
{
    vec3 a = (x            + 0.0245786) * x;
    vec3 b = (x * 0.983729 + 0.4329510) * x + 0.238081;
    
    return a / b;
}


vec3 ToneTF0(vec3 x)
{
    vec3 a = (x            + 0.0509184) * x;
    vec3 b = (x * 0.973854 + 0.7190130) * x + 0.0778594;
    
    return a / b;
}

vec3 ToneTF1(vec3 x)
{
    vec3 a = (x          + 0.0961727) * x;
    vec3 b = (x * 0.9797 + 0.6157480) * x + 0.213717;
    
    return a / b;
}

vec3 ToneTF2(vec3 x)
{
    vec3 a = (x            + 0.0822192) * x;
    vec3 b = (x * 0.983521 + 0.5001330) * x + 0.274064;
    
    return a / b;
}


// https://twitter.com/jimhejl/status/1137559578030354437
vec3 ToneMapFilmicALU(vec3 x)
{
    x *= 0.665;
    
   #if 0
    x = max(vec3(0.0), x - 0.004f);
    x = (x * (6.2 * x + 0.5)) / (x * (6.2 * x + 1.7) + 0.06);
    
    x = sRGB_EOTF(x);
   #else
    x = max(vec3(0.0), x);
    x = (x * (6.2 * x + 0.5)) / (x * (6.2 * x + 1.7) + 0.06);
    
    x = pow(x, vec3(2.2));// using gamma instead of sRGB_EOTF + without x - 0.004f looks about the same
   #endif
    
    return x;
}


vec3 Tonemap_ACESFitted(vec3 srgb)
{
    vec3 color = srgb * ACESInputMat;
   
   #if 1
    color = ToneTF2(color);
   #else
    color = RRTAndODTFit(color);
   #endif
    
    color = color * ACESOutputMat;

    return color;
}

vec3 Tonemap_ACESFitted2(vec3 acescg)
{
    vec3 color = acescg * RRT_SAT;
    
   #if 1
    color = ToneTF2(color); 
   #elif 1
    //color = RRTAndODTFit(color);
   #elif 1
    //color = ToneMapFilmicALU(color);
   #endif
    
    color = color * ACESOutputMat;
    //color = ToneMapFilmicALU(color);

    return color;
}

vec3 ColorGrade(vec3 col)
{
    col = ACEScct_from_Linear(col);
    {
        vec3 s = vec3(1.1, 1.2, 1.0);
        vec3 o = vec3(0.1, 0.0, 0.1);
        vec3 p = vec3(1.4, 1.3, 1.3);
        
        col = pow(col * s + o, p);
    }
    col = Linear_from_ACEScct(col);
    
    return col;
}


//=====================================================================
// M matrix, for encoding

const mat3 M = mat3(
    0.2209, 0.3390, 0.4184,
    0.1138, 0.6780, 0.7319,
    0.0102, 0.1130, 0.2969);

// Inverse M matrix, for decoding
const mat3 InverseM = mat3(
    6.0013,    -2.700,    -1.7995,
    -1.332,    3.1029,    -5.7720,
    0.3007,    -1.088,    5.6268);   

vec4 logLuvEncode(in vec3 vRGB)
{
    vec4 vResult;
    vec3 Xp_Y_XYZp = M * vRGB;
    Xp_Y_XYZp = max(Xp_Y_XYZp, vec3(1.e-6, 1.e-6, 1.e-6));
    vResult.xy = Xp_Y_XYZp.xy / Xp_Y_XYZp.z;
    float Le = 2.0 * log2(Xp_Y_XYZp.y) + 127.0;
    vResult.w = fract(Le);
    vResult.z = (Le - (floor(vResult.w*255.0))/255.0)/255.0;
    return vResult;
}

vec3 logLuvDecode(in vec4 vLogLuv)
{

    float Le = vLogLuv.z * 255. + vLogLuv.w;
    vec3 Xp_Y_XYZp;
    Xp_Y_XYZp.y = exp2((Le - 127.) / 2.);
    Xp_Y_XYZp.z = Xp_Y_XYZp.y / vLogLuv.y;
    Xp_Y_XYZp.x = vLogLuv.x * Xp_Y_XYZp.z;
    vec3 vRGB = InverseM * Xp_Y_XYZp;
    return max(vRGB, 0.0);
}
