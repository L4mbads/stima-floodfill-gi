
const vec2[8] offsets = vec2[8](vec2(1./8.,-3./8.),
                            vec2(-1.,3.)/8.,
                            vec2(5.0,1.)/8.,
                            vec2(-3,-5.)/8.,
                            vec2(-5.,5.)/8.,
                            vec2(-7.,-1.)/8.,
                            vec2(3,7.)/8.,
                            vec2(7.,-7.)/8.);



const float[25] kernel = float[25](
    1.0f/256.0f,
    1.0f/64.0f,
    3.0f/128.0f,
    1.0f/64.0f,
    1.0f/256.0f,
    
    1.0f/64.0f,
    1.0f/16.0f,
    3.0f/32.0f,
    1.0f/16.0f,
    1.0f/64.0f,

    3.0f/128.0f,
    3.0f/32.0f,
    9.0f/64.0f,
    3.0f/32.0f,
    3.0f/128.0f,
   
    1.0f/64.0f,
    1.0f/16.0f,
    3.0f/32.0f,
    1.0f/16.0f,
    1.0f/64.0f,
    
    1.0f/256.0f,
    1.0f/64.0f,
    3.0f/128.0f,
    1.0f/64.0f,
    1.0f/256.0f
);

const vec2[25] offset = vec2[25](
    vec2(-2,-2),
    vec2(-1,-2),
    vec2(0,-2),
    vec2(1,-2),
    vec2(2,-2),
    
    vec2(-2,-1),
    vec2(-1,-1),
    vec2(0,-1),
    vec2(1,-1),
    vec2(2,-1),
    
    vec2(-2,0),
    vec2(-1,0),
    vec2(0,0),
    vec2(1,0),
    vec2(2,0),
    
    vec2(-2,1),
    vec2(-1,1),
    vec2(0,1),
    vec2(1,1),
    vec2(2,1),
    
    vec2(-2,2),
    vec2(-1,2),
    vec2(0,2),
    vec2(1,2),
    vec2(2,2)
);

const vec2[9] offset2 = vec2[9](
    vec2(-1,-1),
    vec2(0,-1),
    vec2(1,-1),
    vec2(-1,0),
    vec2(0,0),
    vec2(1,0),
    vec2(-1,1),
    vec2(0,1),
    vec2(1,1)
);

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

const float[5] ff = float[5](
 2.7, 2.6, 2.5, 2.4, 2.3
);

const float[5] c_phi = float[5](
 5.0, 4.0, 3.0, 2.0, 1.0
);

const float cs_phi = 10.,
            //n_phi = 8.,
            d_phi = 1.0/0.92;

const float gaussian_3[3] = float[3](
    0.25,
    0.5,
    0.25
);

uniform float far;

float blurvar(sampler2D var, vec2 tc) {
    float s,w;

    for(int i=0; i<9; i++)
    {
        vec2 offset = offset2[i]* pixelSize;
        vec2 uv     = tc+offset;

        if(clamp(uv, vec2(0.0), vec2(TAAUres)) != uv) {continue;}

        s += texture(var, uv).a * kernel2[i];
        w += kernel2[i];

    }

    return max((s/w), 1.e-3);
}

/*
3x3 Median
Morgan McGuire and Kyle Whitson
http://graphics.cs.williams.edu


Copyright (c) Morgan McGuire and Williams College, 2006
All rights reserved.
*/

#define s2(a, b)                temp = a; a = min(a, b); b = max(temp, b);
#define mn3(a, b, c)            s2(a, b); s2(a, c);
#define mx3(a, b, c)            s2(b, c); s2(a, c);

#define mnmx3(a, b, c)          mx3(a, b, c); s2(a, b);                                   // 3 exchanges
#define mnmx4(a, b, c, d)       s2(a, b); s2(c, d); s2(a, c); s2(b, d);                   // 4 exchanges
#define mnmx5(a, b, c, d, e)    s2(a, b); s2(c, d); mn3(a, c, e); mx3(b, d, e);           // 6 exchanges
#define mnmx6(a, b, c, d, e, f) s2(a, d); s2(b, e); s2(c, f); mn3(a, b, c); mx3(d, e, f); // 7 exchanges

float median(sampler2D var, vec2 tc) {

  float v[9] = float[9](0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0);

  // Add the pixels which make up our window to the pixel array.
  for(int dX = -1; dX <= 1; ++dX) {
    for(int dY = -1; dY <= 1; ++dY) {       
      vec2 offset = vec2(float(dX), float(dY));
                   
      // If a pixel in the window is located at (x+dX, y+dY), put it at index (dX + R)(2R + 1) + (dY + R) of the
      // pixel array. This will fill the pixel array, with the top left pixel of the window at pixel[0] and the
      // bottom right pixel of the window at pixel[N-1].
      v[(dX + 1) * 3 + (dY + 1)] = (texture(var, tc + offset * pixelSize).a);
    }
  }

  float temp;

  // Starting with a subset of size 6, remove the min and max each time
  mnmx6(v[0], v[1], v[2], v[3], v[4], v[5]);
  mnmx5(v[1], v[2], v[3], v[4], v[6]);
  mnmx4(v[2], v[3], v[4], v[7]);
  mnmx3(v[3], v[4], v[8]);
  return max((v[4]), 1.e-4);

}

const float[5] stepOffset = float[5](1.0, 2.0, 4.0, 8.0, 16.);
//const float[5] stepOffset = float[5](16.0, 8.0, 4.0, 2.0, 1.0);

uniform int hideGUI;

/*
https://github.com/cryscan/bevy-hikari/blob/main/src/shaders/denoise.wgsl - good shit i mean reference
*/

float spatialVarianceEstimate(sampler2D tex, vec2 coord) {

    float moment1,moment2,momentCount;

    for(int i = 0; i < 9; i++) {

            vec2 offset = offset2[i]*pixelSize;
            vec2 uv     = coord+offset;
            
            if(clamp(uv, vec2(0.0), vec2(TAAUres)) != uv) {continue;}
            
            vec4 ctmp  = texture(tex, uv);
            moment1 += luma(ctmp.rgb);
            moment2 += moment1*moment1;
            momentCount++;

    }

        float mean = moment1/momentCount;
        float variance = moment2 / momentCount - pow2(mean);

    return max(1.e-4, sqrt(variance));

}

float getGeometryWeight(vec3 p0, vec3 n0, vec3 p, float pdn) {
    vec3 ray = p - p0;
    float distToPlane = dot(n0, normalize(ray));
    float w = clamp01(1.0 - pow(abs(distToPlane), 0.5));
    return w;
}




vec4 atrous(sampler2D ctex, sampler2D stex, sampler2D ntex, float dval, vec2 tc, int stepIndex, bool blur, float a, out vec3 specular) {

    #ifndef SpatialFilter
        specular = texture(stex, tc).rgb;
        return texture2D(ctex, tc);
    #else

        
        float accum = min(1.0, texture(colortex6, tc).b/4.);

        float stepWidth = stepOffset[stepIndex];

        dval = toViewSpaceDepth(dval);


        vec4 cval  = texture2D(ctex, tc);


        vec3 nval2 = texture(ntex, tc).rgb*2.0-1.0;

        float lumaval = luma(cval.rgb);
        float var =  cval.a;

        float moment1,moment2,sMoment1,sMoment2,momentCount,cum_w,tw;
        vec3 sum;

        float rval = texture(stex, tc).a;
        float sCum_w = kernel2[4];
        vec3 sSum = texture(stex, tc).rgb * sCum_w;
        float sLuma = luma(sSum);

        cum_w = kernel2[4];
        sum    = cval.rgb * cum_w;
        
        float vCum_w = kernel2[4];
        tw = pow2(vCum_w) * var;

        moment1 = lumaval;
        moment2 = pow2(lumaval);
        sMoment1 = sLuma;
        sMoment2= pow2(sLuma);
        momentCount = 1.0;
        vec2 step   = pixelSize * (stepWidth );

        //const float v_phi = 1.0/max(c_phi[BlockLightShadowSharpness-1]  * pow(((blurvar(ctex, tc))), 0.5)*20. , 1.e-9);//c_phi[ShadowSharpness-1]
         const float v_phi2 = 1.0/max(c_phi[BlockLightShadowSharpness-1]  * pow(((blurvar(ctex, tc))), 0.5) , 1.e-9);//c_phi[ShadowSharpness-1]
        const float n_phi = mix(2., 10., accum);

        const float sV_phi = 1.0/(mix(50., 10., accum)*sLuma);

        for(int i=0; i<9; i++) {
            
            vec2 offset = offset2[i]*step;
            vec2 uv     = tc+offset;
            float dtmp = toViewSpaceDepth(texture2D(depthtex0, uv/TAAUres).r);
            
            if(clamp(uv, vec2(0.0), vec2(TAAUres)) != uv || i == 4 || dtmp >= 1.0) {continue;}
            
            vec4 ctmp  = texture2D(ctex, uv);
            float lumatmp = luma(ctmp.rgb);
            vec3 ntmp2 = texture(ntex, uv).rgb*2.0-1.0;
            
            vec3 stmp  = texture2D(stex, uv).rgb;
            float rtmp = texture(stex, uv).a;
            float sLumatmp = luma(stmp);

            
           float c_w = max(exp(-(abs(lumatmp-lumaval)*v_phi2*0.2)), EPS);
            float c_w2 = max(exp(-(abs(lumatmp-lumaval)*v_phi2*mix(5.0, 1.0, accum)*3. )), EPS);
             //float c_w2 = max(exp(-(abs(lumatmp-lumaval)*v_phi/(max(EPS, lumaval)))), EPS);
            float sC_w = max(exp(-(abs(sLumatmp-sLuma)*sV_phi)), EPS);

            float r_w = exp(-((abs(rval-rtmp)*24.)));

            float n_w = (pow(max0(dot(ntmp2, nval2)), n_phi ));
            float d_w = exp(-((abs(dval-dtmp) * d_phi)));
            //float g_w = hideGUI==1?d_w: mix(getGeometryWeight(viewPos, i_octahedral_24(uint(texture(colortex5, tc).b)), screenToView(vec3(uv/TAAUres, dtmp)), accum*100. / (1.0 + (dval))), d_w, d_w);
         
            //d_w = mix(1.0, d_w, pow(dval, 8.));
            c_w2 = mix(1., c_w2, accum);
            c_w = mix(1., c_w, accum);
            //sC_w = mix(1.0, sC_w, accum);
            //n_w = mix(1.0, n_w, accum);

            float weight  = max(EPS, c_w*d_w*n_w* kernel2[i]) ;
            float vWeight  = max(EPS, c_w2*n_w*d_w* kernel2[i]) ;
            float sWeight  = max(EPS, d_w*sC_w*n_w*r_w* kernel2[i]) ;

            tw    += pow2(vWeight) * cval.a;
            sum   += ctmp.rgb * weight;
            cum_w += weight;
            vCum_w += vWeight;

            sSum   += stmp * sWeight;
            sCum_w += sWeight;

            moment1 += lumatmp ;
            moment2 += pow2(lumatmp);
            sMoment1 += sLumatmp;
            sMoment2 += pow2(sLumatmp);
            momentCount += (1.);
        }

        
        vec3 irradiance = clamp((sum/cum_w), 0.0,  65535.0);
        specular = clamp(sSum/sCum_w, 0.0, 65535.);

      
        float mean = moment1/momentCount;
        float variance = moment2 / momentCount - pow2(mean);


        if(lumaval > mean + (ff[FireflyRejectionStrength-1]) * max(sqrt(variance), EPS)) {
            irradiance = mean / lumaval * irradiance;
        }






        mean = sMoment1/momentCount;
        variance = sMoment2 / momentCount - pow2(mean);


        if(sLuma > mean + (ff[FireflyRejectionStrength-1]) * max(sqrt(variance), EPS)) {
            specular = mean / sLuma * specular;
        }
        

        specular =  mix(texture(stex, tc).rgb, specular, 1.);

        var = abs(tw/max(pow2(vCum_w), EPS));

        return vec4(irradiance, var);

    #endif
}

    


