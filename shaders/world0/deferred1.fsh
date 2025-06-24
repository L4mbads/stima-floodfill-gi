#version 430 compatibility
#include "/lib/Settings.glsl"



/*RENDERTARGETS:13*/

layout (location = 0) out vec4 LUT;

in vec2 coord;

uniform sampler2D colortex13;
uniform vec2 resolution;
uniform float screenBrightness;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunVector;

#include "/lib/Atmosphere.glsl"

void main() {
   
   vec4 history = texelFetch(colortex13, ivec2(gl_FragCoord.xy), 0);
   LUT = history;

  

    if (gl_FragCoord.x <= (tLUTRes.x+1.5) && gl_FragCoord.y <= (tLUTRes.y+1.5) && history.a < 1.0) {

        float u = clamp(gl_FragCoord.x, 0.0, tLUTRes.x-1.0)/tLUTRes.x;
        float v = clamp(gl_FragCoord.y, 0.0, tLUTRes.y-1.0)/tLUTRes.y;
        
        float sunCosTheta = 2.0*u - 1.0;
        float sunTheta = safeacos(sunCosTheta);
        float height = mix(groundRadiusMM, atmosphereRadiusMM, v);
        
        vec3 pos = vec3(0.0, height, 0.0); 
        vec3 sunDir = normalize(vec3(0.0, sunCosTheta, -sin(sunTheta)));
        
        LUT = vec4(getSunTransmittance(pos, sunDir), 1.0);
        return;
    }


    
    else if ((gl_FragCoord.x <= (msLUTRes.x+1.5)  && gl_FragCoord.y <= (msLUTRes.y+1.5) + tLUTRes.y  + 2.0) && gl_FragCoord.y >= tLUTRes.y + 2.0  && history.a < 1.0) {

        float u = clamp(gl_FragCoord.x, 0.0, msLUTRes.x-1.0)/msLUTRes.x;
        float v = clamp(gl_FragCoord.y - (tLUTRes.y + 2.0), 0.0, msLUTRes.y-1.0)/msLUTRes.y;
        
        float sunCosTheta = 2.0*u - 1.0;
        float sunTheta = safeacos(sunCosTheta);
        float height = mix(groundRadiusMM, atmosphereRadiusMM, v);
        
        vec3 pos = vec3(0.0, height, 0.0); 
        vec3 sunDir = normalize(vec3(0.0, sunCosTheta, -sin(sunTheta)));
        
        vec3 lum, f_ms;
        getMulScattValues(pos, sunDir, lum, f_ms);
        
        // Equation 10 from the paper.
        vec3 psi = lum  / (1.0 - f_ms); 

        LUT = vec4(psi, 1.0);
        //LUT = vec4(1.0);
        return;

    }


    
    else if ((gl_FragCoord.x <= (skyLUTRes.x+1.5) + (tLUTRes.x+3.0) && gl_FragCoord.y <= (skyLUTRes.y+1.5)) && gl_FragCoord.x >= tLUTRes.x+3.0 ) {

    
        float u = clamp(gl_FragCoord.x - (tLUTRes.x+3.0), 0.0, skyLUTRes.x-1.0)/skyLUTRes.x;
        float v = clamp(gl_FragCoord.y, 0.0, skyLUTRes.y-1.0)/skyLUTRes.y;
        
        float azimuthAngle = (u - 0.5)*2.0*PI;
        // Non-linear mapping of altitude. See Section 5.3 of the paper.
        float adjV;
        if (v < 0.5) {
            float coord = 1.0 - 2.0*v;
            adjV = -coord*coord;
        } else {
            float coord = v*2.0 - 1.0;
            adjV = coord*coord;
        }
        
        float height = length(viewPos);
        vec3 up = viewPos / height;
        float horizonAngle = safeacos(sqrt(height * height - groundRadiusMM * groundRadiusMM) / height) - 0.5*PI;
        float altitudeAngle = adjV*0.5*PI - horizonAngle;
        
        float cosAltitude = cos(altitudeAngle);
        vec3 rayDir = vec3(cosAltitude*sin(azimuthAngle), sin(altitudeAngle), -cosAltitude*cos(azimuthAngle));
        
        float sunAltitude = (0.5*PI) - acos(dot(sunVector, up));
        vec3 sunDir = vec3(0.0, sin(sunAltitude), -cos(sunAltitude));
        
        float atmoDist = rayIntersectSphere(viewPos, rayDir, atmosphereRadiusMM);
        float groundDist = rayIntersectSphere(viewPos, rayDir, groundRadiusMM);
        float tMax = (groundDist < 0.0) ? atmoDist : groundDist;
        vec3 lum = raymarchScattering(viewPos, rayDir, sunDir, tMax, float(numScatteringSteps));
        LUT = vec4(lum, 1.0);
        return;
    } else {
        return;
    }



    
}
