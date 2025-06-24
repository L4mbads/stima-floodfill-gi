vec3 diag3(mat4 mat) { return vec3(mat[0].x, mat[1].y, mat[2].z);      }
vec3 projMAD3(mat4 mat, vec3 v) { return diag3(mat) * v + mat[3].xyz;  }
vec3 transMAD3(mat4 mat, vec3 v) { return mat3(mat) * v + (mat)[3].xyz; }

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferPreviousModelView;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform sampler2D shadowtex0;

#define Shadow_Z_Stretch 3.0
#define Shadow_Bias 0.8


float distortionFactor(vec2 shadowSpace) {
    float dist = length(abs(shadowSpace * 1.165));
    float distortion = ((1.0 - Shadow_Bias) + dist * Shadow_Bias) * 0.97;
    
    return distortion;
}

vec3 distortShadowSpace(vec3 shadowSpace) {
    shadowSpace = shadowSpace * 2.0 - 1.0;
    shadowSpace = shadowSpace / vec3(vec2(distortionFactor(shadowSpace.xy)), Shadow_Z_Stretch);
    shadowSpace = shadowSpace * 0.5 + 0.5;

    return shadowSpace;
}


float visibility(sampler2D shadow, vec3 shadowSpace, float bias, out float sunDist) {

    sunDist = textureLod(shadow, shadowSpace.xy, 0.).x;
    return step(shadowSpace.z - bias, sunDist);
}

vec3 calculateShadow(sampler2D shadow, vec3 shadowSpace, float bias, out float sunDist) {
    shadowSpace = distortShadowSpace(shadowSpace);
    shadowSpace.xy = shadowSpace.xy * 0.5 + 0.5;
    if (floor(shadowSpace.xy) != vec2(0.0) || shadowSpace.z >= 1.0) return vec3(1.0);

    float v0 = visibility(shadowtex0, shadowSpace, bias, sunDist);
    float v1 = visibility(shadow, shadowSpace, bias, sunDist);
    vec4 c0 = texture(shadowcolor0, shadowSpace.xy);
    return mix(c0.rgb *(1.0-c0.a) * v1, vec3(1.0f), v0);
}

vec3 calculateShadow(sampler2D shadow, vec3 shadowSpace, float bias) {
    float sunDist;
    shadowSpace = distortShadowSpace(shadowSpace);
    shadowSpace.xy = shadowSpace.xy * 0.5 + 0.5;
    if (floor(shadowSpace.xy) != vec2(0.0) || shadowSpace.z >= 1.0) return vec3(1.0);

    float v0 = visibility(shadowtex0, shadowSpace, bias, sunDist);
    float v1 = visibility(shadow, shadowSpace, bias, sunDist);
    vec4 c0 = texture(shadowcolor0, shadowSpace.xy);
    return mix(c0.rgb *(1.0-c0.a) * v1, vec3(1.0f), v0);
}

vec3 screenToView(vec3 screenPos) {
    screenPos= screenPos * 2.0 - 1.0;
    return projMAD3(gbufferProjectionInverse, screenPos) / (gbufferProjectionInverse[2].w * screenPos.z + gbufferProjectionInverse[3].w);
}


vec3 viewToScreen(vec3 viewPos) {
    return (projMAD3(gbufferProjection, viewPos) / -viewPos.z) * 0.5 + 0.5;
}

vec3 viewToWorld(vec3 viewPos) {
    return mat3(gbufferModelViewInverse) * viewPos + cameraPosition + gbufferModelViewInverse[3].xyz;
}

vec3 worldToView(vec3 worldPos) {
    return mat3(gbufferModelView) * (worldPos - cameraPosition - gbufferModelViewInverse[3].xyz);
}

vec3 screenToFeet(vec3 screenPos) {
    vec3 viewPos = screenToView(screenPos);
    return mat3(gbufferModelViewInverse) * viewPos + gbufferModelViewInverse[3].xyz;

}

vec3 screenToWorld(vec3 screenPos) {
    vec3 feet = screenToFeet(screenPos);
    return feet + cameraPosition;
}


vec3 feetToView(vec3 feetPos) {
    
    return mat3(gbufferModelView) * (feetPos - gbufferModelViewInverse[3].xyz);

}

vec3 feetToScreen(vec3 feetPos) {
    
    vec3 viewPos = mat3(gbufferModelView) * (feetPos - gbufferModelViewInverse[3].xyz);

    return viewToScreen(viewPos);

}

vec3 feetToShadowScreen(vec3 feet) {
    return projMAD3(shadowProjection, transMAD3(shadowModelView, feet)) * 0.5 + 0.5;

}


float toViewSpaceDepth(float depth) {
    depth = depth * 2.0 - 1.0;
    return -1.0 / (depth * gbufferProjectionInverse[2][3] + gbufferProjectionInverse[3][3]);
}

float toShadowViewSpaceDepth(float depth) {
    depth = depth * 2.0 - 1.0;
    return -1.0 / (depth * shadowProjectionInverse[2][3] + shadowProjectionInverse[3][3]);
}


vec3 toPrevViewScreenLinearized(vec2 screenPos, float depth) {
   vec3 prevWorld = screenToFeet(vec3(screenPos, depth)) + cameraPosition + (depth < 0.56 ? vec3(0.0) : cameraPosition - previousCameraPosition);
   vec3 prevView = mat3(gbufferPreviousModelView) * (prevWorld - previousCameraPosition - gbufferModelViewInverse[3].xyz);
   return (projMAD3(gbufferPreviousProjection, prevView) / -prevView.z) * 0.5 + 0.5;
}

//function from eldeston snippet
vec2 toPrevScreenPos(vec2 currScreenPos, float depth){
    vec3 currViewPos = vec3(vec2(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y) * (currScreenPos.xy * 2.0 - 1.0) + gbufferProjectionInverse[3].xy, gbufferProjectionInverse[3].z);
    currViewPos /= (gbufferProjectionInverse[2].w * (depth * 2.0 - 1.0) + gbufferProjectionInverse[3].w);
    vec3 currFeetPlayerPos = mat3(gbufferModelViewInverse) * currViewPos + gbufferModelViewInverse[3].xyz;

    vec3 prevFeetPlayerPos = depth > 0.56 ? currFeetPlayerPos + cameraPosition - previousCameraPosition : currFeetPlayerPos;
    vec3 prevViewPos = mat3(gbufferPreviousModelView) * prevFeetPlayerPos + gbufferPreviousModelView[3].xyz;
    vec2 finalPos = vec2(gbufferPreviousProjection[0].x, gbufferPreviousProjection[1].y) * prevViewPos.xy + gbufferPreviousProjection[3].xy;
    return (finalPos / -prevViewPos.z) * 0.5 + 0.5;
}

mat3 constructViewTBN(vec3 viewNormal) {
    vec3 tangent = normalize(cross(gbufferModelViewInverse[1].xyz, viewNormal));
    return mat3(tangent, cross(tangent, viewNormal), viewNormal);
}

vec3 toPrevScreenPos2(vec3 currViewPos, float depth){
        vec3 currFeetPlayerPos = mat3(gbufferModelViewInverse) * currViewPos + gbufferModelViewInverse[3].xyz;

    vec3 prevFeetPlayerPos = depth > 0.56 ? currFeetPlayerPos + cameraPosition - previousCameraPosition : currFeetPlayerPos;
    vec3 prevViewPos = mat3(gbufferPreviousModelView) * prevFeetPlayerPos + gbufferPreviousModelView[3].xyz;
    vec2 finalPos = vec2(gbufferPreviousProjection[0].x, gbufferPreviousProjection[1].y) * prevViewPos.xy + gbufferPreviousProjection[3].xy;
    return vec3((finalPos / -prevViewPos.z) * 0.5 + 0.5, -prevViewPos.z);
}