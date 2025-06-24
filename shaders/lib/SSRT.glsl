#define BINARY_REFINEMENT 0
#define BINARY_COUNT 4
#define BINARY_DECREASE 0.5



void binarySearch(inout vec3 rayPos, vec3 rayDir) {
    for(int i = 0; i < BINARY_COUNT; i++) {
        rayPos += sign(texture(depthtex0, rayPos.xy).r - rayPos.z) * rayDir;
        // Going back and forth using the delta of the 2 different depths as a parameter for sign()
        rayDir *= BINARY_DECREASE;
        // Decreasing the step length (to slowly tend towards the intersection)
    }
}

// The favorite raytracer of your favorite raytracer
bool raytrace(vec3 viewPos, vec3 rayDir, int stepCount, float jitter, out vec3 rayPos) {
    // "out vec3 rayPos" is our ray's position, we use it as an "out" parameter to be able to output both the intersection check and the hit position

    rayPos  = viewToScreen(viewPos);
    // Starting position in screen space, it's better to perform space conversions OUTSIDE of the loop to increase performance
    rayDir  = viewToScreen(viewPos + rayDir) - rayPos;
    rayDir *= minof((sign(rayDir) - rayPos) / rayDir) * (1.0 / stepCount);
    // Calculating the ray's direction in screen space, we multiply it by a "step size" that depends on a few factors from the DDA algorithm

    bool intersect = false;
    // Our intersection isn't found by default

    rayPos += rayDir * jitter;
    // We settle the ray's starting point and jitter it
    // Jittering reduces the banding caused by a low amount of steps, it's basically multiplying the direction by a random value (like noise)
    for(int i = 0; i <= stepCount && !intersect; i++, rayPos += rayDir) {
        // Loop until we reach the max amount of steps OR if an intersection is found, add 1 at each iteration AND march the ray (position += direction)

        if(clamp01(rayPos.xy) != rayPos.xy) return false;
        // Checking if the ray goes outside of the screen (if clamping the coordinates to [0;1] returns a different value, then we're outside)
        // There's no need to continue ray marching if the ray goes outside of the screen

        float depth         = (texture(depthtex0, rayPos.xy).r);
        // Sampling the depth at the ray's position
        // We use depthtex1 to get the depth of all blocks EXCEPT translucents, it's useful for refractions
        float depthLenience = max(abs(rayDir.z) * 3.0 , 0.02 / pow2(viewPos.z));
        // DrDesten's depth lenience factor, it's used as a "threshold" for our intersection's depth

        intersect = abs(depthLenience - (rayPos.z - depth)) < depthLenience && depth >= 0.56;
        // Comparing depths to see if we hit something AND checking if the depth is above 0.56 (= if we didn't intersect the player's hand)
    }

    #if BINARY_REFINEMENT == 1
        binarySearch(rayPos, rayDir);
        // Binary search for some extra accuracy
    #endif

    return intersect;
    // Outputting the boolean
}
/*
vec3 raymarchFloodfill(vec3 origin, vec3 dir, int stepCount, float jitter) {
    vec3 pos = origin+dir*jitter;
    vec3 r = vec3(0.0);

    for(int i = 0: i <= stepCount && !intersect; i++, pos+=dir) {

        r+=texelFetch(colortex2, GetVoxelStoragePos(ivec3(floor(sceneSpaceToVoxelSpace(pos)))), 0).rgb;

    }
}
*/