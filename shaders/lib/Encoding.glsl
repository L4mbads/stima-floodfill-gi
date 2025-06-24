
//==============================
// The MIT License
// Copyright © 2017 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//-------------------------------------------------------------------------------------------
uint   packSnorm2x12(vec2 v) { uvec2 d = uvec2(round(2047.5 + v*2047.5)); return d.x|(d.y<<12u); }
uint   packSnorm2x8( vec2 v) { uvec2 d = uvec2(round( 127.5 + v* 127.5)); return d.x|(d.y<< 8u); }
vec2 unpackSnorm2x8( uint d) { return vec2(uvec2(d,d>> 8)& 255u)/ 127.5 - 1.0; }
vec2 unpackSnorm2x12(uint d) { return vec2(uvec2(d,d>>12)&4095u)/2047.5 - 1.0; }

//-------------------------------------------------------------------------------------------


vec2 msign( vec2 v ) {return vec2( (v.x>=0.0) ? 1.0 : -1.0, (v.y>=0.0) ? 1.0 : -1.0 );}
vec2 osign( vec2 v ) {return vec2( (v.x>=0.0) ? 1.0 : 0.0, (v.y>=0.0) ? 1.0 : 0.0 );}
vec3 msign( vec3 v ) {return vec3( (v.x>=0.0) ? 1.0 : -1.0, (v.y>=0.0) ? 1.0 : -1.0 , (v.z>=0.0) ? 1.0 : -1.0 );}

uint octahedral_24( in vec3 nor ) {

    nor /= ( abs( nor.x ) + abs( nor.y ) + abs( nor.z ) );
    nor.xy = (nor.z >= 0.0) ? nor.xy : (1.0-abs(nor.yx))*msign(nor.xy);
    return packSnorm2x12(nor.xy);
}
vec3 i_octahedral_24( uint data ) {

    vec2 v = unpackSnorm2x12(data);
    vec3 nor = vec3(v, 1.0 - abs(v.x) - abs(v.y)); // Rune Stubbe's version,
    float t = max(-nor.z,0.0);                     // much faster than original
    nor.x += (nor.x>0.0)?-t:t;                     // implementation of this
    nor.y += (nor.y>0.0)?-t:t;                     // technique
    return normalize( nor );
}

uint octahedral_8( in vec3 nor )
{
    nor.xy /= ( abs( nor.x ) + abs( nor.y ) + abs( nor.z ) );
    nor.xy  = (nor.z >= 0.0) ? nor.xy : (1.0-abs(nor.yx))*msign(nor.xy);
    uvec2 d = uvec2(round(7.5 + nor.xy*7.5));  return d.x|(d.y<<4u);
}
vec3 i_octahedral_8( uint data )
{
    uvec2 iv = uvec2( data, data>>4u ) & 15u; vec2 v = vec2(iv)/7.5 - 1.0;
    vec3 nor = vec3(v, 1.0 - abs(v.x) - abs(v.y)); // Rune Stubbe's version,
    float t = max(-nor.z,0.0);                     // much faster than original
    nor.x += (nor.x>0.0)?-t:t;                     // implementation of this
    nor.y += (nor.y>0.0)?-t:t;                     // technique
    return normalize( nor );
}

uint spheremap_8( in vec3 nor )
{
    vec2 v = nor.xy * inversesqrt(2.0*nor.z+2.0);
    return (uint(7.5+v.y*7.5)<<4) | uint(7.5+v.x*7.5);
}
vec3 i_spheremap_8( uint data )
{
    vec2 v = vec2(data&15u,data>>4)/7.0-1.0;
    float f = dot(v,v);
    return vec3( 2.0*v*sqrt(1.0-f), 1.0-2.0*f );
}

uint octahedral_16( in vec3 nor )
{
    nor /= ( abs( nor.x ) + abs( nor.y ) + abs( nor.z ) );
    nor.xy = (nor.z >= 0.0) ? nor.xy : (1.0-abs(nor.yx))*msign(nor.xy);
    return packSnorm2x8(nor.xy);
}
vec3 i_octahedral_16( uint data )
{
    vec2 v = unpackSnorm2x8(data);
    vec3 nor = vec3(v, 1.0 - abs(v.x) - abs(v.y)); // Rune Stubbe's version,
    float t = max(-nor.z,0.0);                     // much faster than original
    nor.x += (nor.x>0.0)?-t:t;                     // implementation of this
    nor.y += (nor.y>0.0)?-t:t;                     // technique
    return normalize( nor );
}
//==============================

struct material {

    vec3 albedo;
    vec3 normal;
    vec3 geometryNormal;
    float roughness;
    float f0;
    float porosity;
    float sss;
    float ao;
    float height;
    float emission;
    bool isMetal;
    bool isTransparent;
    bool isWater;
    float opacity;

};

struct reservoir {
    //vec3 originPos;
    //vec3 originNormal;
    vec3 samplePos;
    vec3 sampleNormal;
    vec3 radiance;
    int M;
    float avgW;

};

vec3 getGeometryNormal(vec3 normal) {
    vec3 n = normalize(normal);
 float mx = max(abs(n.x), max(abs(n.y), abs(n.z)));
vec3 gm = n;
if(abs(mx - abs(n.x))<0.01){
    gm = normalize(vec3(n.x, 0., 0.));
}else if(abs(mx - abs(n.y))<0.01){
    gm = normalize(vec3(0., n.y, 0.));
}else if(abs(mx - abs(n.z))<0.01){
    gm = normalize(vec3(0., 0., n.z));
}
return gm;
}



vec3 decodeNormal(vec2 n, mat3 tbn) {
    vec3 normal;
         normal.xy = n * 2.0 - 1.0;
         normal = vec3(normal.xy, sqrt(1.0 - dot(normal.xy, normal.xy)));
         normal = normalize(clamp(normal, -1.0, 1.0));

         normal = tbn * normal;

    return (normal);

}

void encodeGBuffer(out uvec3 gBuffer, vec4 colorTex, vec4 normalTex, vec3 geomNormal, vec4 specularTex, mat3 tbn, float r, float water) {

    gBuffer = uvec3(0u);

    uvec3 albedo   = uvec3(colorTex.rgb*255.);
    uint  normal   = octahedral_24(decodeNormal(normalTex.xy, tbn));
    uint geometryNormal = octahedral_8(  geomNormal);
    uvec4 specular = uvec4(specularTex*255.);

    uint isTransparent = uint(float(1.0 > colorTex.a));
    uint isWater = uint(float(water>0.0));
    uint ao = uint(normalTex.b * 255.);
    uint height = uint(normalTex.a * 255.);
    uint opacity = uint(colorTex.a * 127.);

    specular.a = specular.a == 255u ? 0u : specular.a; 

    gBuffer.r = (albedo.r << 24u) | (albedo.g << 16u) | (albedo.b << 8u) | (isTransparent << 7u) | (specular.a >> 1u);
    gBuffer.g = (normal << 8u) | (ao);
    gBuffer.b = (specular.r << 24u) | (specular.g << 16u) | (specular.b << 8u) | (isWater << 7u) | opacity;



}


void decodeGBuffer(inout material mat, uvec3 gBuffer) {

    const float maxBit8 = (1.0/255.0);
    const float maxBit7 = (1.0/127.0);

    #ifdef WhiteWorld

        mat.albedo = vec3(1.0) * sRGBtoAP1;
    #else
        mat.albedo        = (vec3( (gBuffer.r >> 24u) & 255u, 
                                  (gBuffer.r >> 16u) & 255u,
                                  (gBuffer.r >> 8u ) & 255u)
                                  * maxBit8) * sRGBtoAP1;
    #endif

    mat.normal        = i_octahedral_24( (gBuffer.g >> 8u ) & 16777215u);

    mat.ao            = ((gBuffer.g) & 255u) * maxBit8;

    

    mat.roughness     = pow2(1.0 - ((gBuffer.b >> 24u) & 255u) * maxBit8);

    mat.f0            = ((gBuffer.b >> 16u) & 255u) * maxBit8;

    //mat.height        = ((gBuffer.b) & 255u) * maxBit8;

    mat.geometryNormal= i_octahedral_8(((gBuffer.b) & 255u));

    mat.emission      = ((gBuffer.r) & 127u) * maxBit7 * 4000.;

    mat.isMetal       = mat.f0 > 229./255.;

    mat.isTransparent = bool((gBuffer.r >> 7u) & 1u);
    mat.isWater       = bool((gBuffer.b >> 7u) & 1u);
    mat.opacity       = ((gBuffer.b)&7u) * maxBit7;


        float specularG = ((gBuffer.b >> 8u) & 255u) * maxBit8;


        mat.sss = specularG < (65.0 / 255.0) ? 0.0 : specularG * (255.0 / 190.0) - (65.0 / 190.0);

        mat.porosity = specularG > (64.0 / 255.0) ? 0.0 : specularG *  (255.0 / 64.0);
}

void encodeReservoir(out uvec4 reservoirData, reservoir reservoir) {
    //uvec4 reservoirData;

    //uvec2 oSign = uvec2(msign(reservoir.originPos.xy));
    //uvec2 sSign = uvec2(osign(reservoir.samplePos.xy));

    //uvec3 oPos = uvec3(abs(reservoir.originPos.xy), clamp(-reservoir.originPos.z, 0.0, exp2(14)))
    //uvec3 sPos = uvec3(abs(reservoir.samplePos.xy * 1023.0), clamp(abs(reservoir.samplePos.z), 0.0, 4095.0));

    //uint oNorm = octahedral_16(reservoir.originNormal);
// |127|
    vec3 normalizedPos = ( (reservoir.samplePos + 127.) / 254.);
    uvec3 sPos = uvec3(normalizedPos *65535.); 

    uint sNorm = octahedral_16(reservoir.sampleNormal);

    uvec3 radiance = uvec3(clamp(reservoir.radiance, 0.0, 65535.0));

    uint M = uint(reservoir.M);

    uint avgW = uint(clamp(reservoir.avgW, 0.0, 65535.0));

    uint combined = packHalf2x16(vec2(reservoir.M + clamp(normalizedPos.z,0.0, 0.9999999), reservoir.avgW));


    reservoirData.r = (sPos.x << 16u) | sPos.y;
    reservoirData.g =  (sNorm << 16u ) | radiance.b;
    reservoirData.b = (radiance.r << 16u) | (radiance.g);
    reservoirData.a = combined;
}

void decodeReservoir(inout reservoir reservoirData, uvec4 reservoirBuffer) {


    reservoirData.sampleNormal = i_octahedral_16( (reservoirBuffer.g >> 16u ) & 65535u);

    reservoirData.radiance = vec3( (uvec2(reservoirBuffer.b) >> uvec2(16u, 0u)) & 65535u, (reservoirBuffer.g) & 65535u);
    vec2 decombined = unpackHalf2x16(reservoirBuffer.a);

    reservoirData.samplePos = vec3( vec2((reservoirBuffer.r >> 16u) & 65535u, reservoirBuffer.r & 65535u)/65535., fract(decombined.x)) * 254 - 127.;

    reservoirData.M = int(floor(decombined.x));

    reservoirData.avgW = decombined.y;



}

/*
void encodeReservoir(out uvec4 reservoirData, reservoir reservoir) {
    //uvec4 reservoirData;


    //uvec2 oSign = uvec2(msign(reservoir.originPos.xy));
    uvec2 sSign = uvec2(osign(reservoir.samplePos.xy));

    //uvec3 oPos = uvec3(abs(reservoir.originPos.xy), clamp(-reservoir.originPos.z, 0.0, exp2(14)))
    uvec3 sPos = uvec3(abs(reservoir.samplePos.xy * 1023.0), clamp(abs(reservoir.samplePos.z), 0.0, 4095.0));

    //uint oNorm = octahedral_16(reservoir.originNormal);
    uint sNorm = octahedral_24(reservoir.sampleNormal);

    uvec4 radiance = uvec4((logLuvEncode(clamp(reservoir.radiance, 0., 65535.)) * 255.0));

    uint M = uint(reservoir.M);

    uint avgW = uint(reservoir.avgW*4294967295.);

    uint combined = packHalf2x16(vec2(reservoir.M, reservoir.avgW));


    reservoirData.r = (sPos.x << 22u) | (sPos.y << 12u) | sPos.z;
    reservoirData.g =  (sNorm << 8u ) | (sSign.x << 7u) | (sSign.y << 6u) | M;
    reservoirData.b = (radiance.r << 24u) | (radiance.g << 16u) | (radiance.b << 8u) | radiance.a << 0u;
    reservoirData.a = combined;
}

void decodeReservoir(inout reservoir reservoirData, uvec4 reservoirBuffer) {

    reservoirData.samplePos = vec3( ((reservoirBuffer.g >> 7u) & 1u)*(2.0-1.0) * ((reservoirBuffer.r >> 22u) & 1023u),
                               ((reservoirBuffer.g >> 6u) & 1u)*(2.0-1.0) * ((reservoirBuffer.r >> 12u) & 1023u),
                                                                  ((reservoirBuffer.r       ) & 4095u)
                              ) * vec3(1.0, 1.0, -1.0);

    reservoirData.sampleNormal = i_octahedral_24( (reservoirBuffer.g >> 8u ) & 16777215u);

    //reservoirData.radiance = vec3( (uvec2(reservoirBuffer.b) >> uvec2(16u, 0u)) & 65535u, (reservoirBuffer.a >> 16u) & 65535u) / 65535.0;

    reservoirData.radiance = logLuvDecode((uvec4(  (reservoirBuffer.b >> 24u) & 255u, (reservoirBuffer.b >> 16u) & 255u, (reservoirBuffer.b >> 8u) & 255u, (reservoirBuffer.b >> 0u)&255u ))/ 255.);

    vec2 decombined = unpackHalf2x16(reservoirBuffer.a);


    reservoirData.M = int(decombined.x);


    reservoirData.avgW = decombined.y;
    //reservoirData.M = int(reservoirBuffer.g & 63u);

    //reservoirData.avgW = (reservoirBuffer.a & 65535u) / 65535.0;
}

*/

reservoir createReservoir(vec3 pos, vec3 normal, vec3 radiance, float pdf) {
    reservoir reservoirData;

    reservoirData.samplePos = pos;

    reservoirData.sampleNormal = normal;

    reservoirData.radiance = radiance;

    reservoirData.M = 1;

    reservoirData.avgW = pdf;

    return reservoirData;
}

bool updateReservoir(in reservoir currR, inout reservoir tempR, float weight, inout float W) {
    W += weight;

    tempR.M += currR.M;

    bool update = randF() * W <= weight;

    if(update) {
        tempR.samplePos = currR.samplePos;
        tempR.sampleNormal = currR.sampleNormal;
        tempR.radiance = currR.radiance;
    }

    return update;
}