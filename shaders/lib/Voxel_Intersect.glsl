const vec3[75][2] bounds = vec3[75][2](
    // Redstone torch off
    vec3[2](vec3(0.4375, 0.0000, 0.4375), vec3(0.5625, 0.6250, 0.5625)),

    // Slabs, stairs bottom
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),

    // Slabs, stairs top
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),

    // Buttons
    vec3[2](vec3(0.0000, 0.3750, 0.3125), vec3(0.1250, 0.6250, 0.6875)),
    vec3[2](vec3(0.8750, 0.3750, 0.3125), vec3(1.0000, 0.6250, 0.6875)),
    vec3[2](vec3(0.3125, 0.3750, 0.0000), vec3(0.6875, 0.6250, 0.1250)),
    vec3[2](vec3(0.3250, 0.3750, 0.8750), vec3(0.6875, 0.6250, 1.0000)),
    vec3[2](vec3(0.3750, 0.0000, 0.3125), vec3(0.6250, 0.1250, 0.6875)),
    vec3[2](vec3(0.3125, 0.0000, 0.3750), vec3(0.6875, 0.1250, 0.6250)),
    vec3[2](vec3(0.3750, 0.8750, 0.3125), vec3(0.6250, 1.0000, 0.6875)),
    vec3[2](vec3(0.3125, 0.8750, 0.3750), vec3(0.6875, 1.0000, 0.6250)),
    vec3[2](vec3(0.0000, 0.3750, 0.3125), vec3(0.0625, 0.6250, 0.6875)),
    vec3[2](vec3(0.9375, 0.3750, 0.3125), vec3(1.0000, 0.6250, 0.6875)),
    vec3[2](vec3(0.3125, 0.3750, 0.0000), vec3(0.6875, 0.6250, 0.0625)),
    vec3[2](vec3(0.3125, 0.3750, 0.9375), vec3(0.6875, 0.6250, 1.0000)),
    vec3[2](vec3(0.3750, 0.0000, 0.3125), vec3(0.6250, 0.0625, 0.6875)),
    vec3[2](vec3(0.3125, 0.0000, 0.3750), vec3(0.6875, 0.0625, 0.6250)),
    vec3[2](vec3(0.3750, 0.9375, 0.3125), vec3(0.6250, 1.0000, 0.6875)),
    vec3[2](vec3(0.3125, 0.9375, 0.3750), vec3(0.6875, 1.0000, 0.6250)),

    // Pressure plates
    vec3[2](vec3(0.0625, 0.0000, 0.0625), vec3(0.9375, 0.06250, 0.9375)),
    vec3[2](vec3(0.0625, 0.0000, 0.0625), vec3(0.9375, 0.03125, 0.9375)),

    // Doors and trapdoors
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.1875, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(0.1875, 1.0000, 1.0000)),
    vec3[2](vec3(0.8125, 0.0000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 1.0000, 0.1875)),
    vec3[2](vec3(0.0000, 0.0000, 0.8125), vec3(1.0000, 1.0000, 1.0000)),
    vec3[2](vec3(0.0000, 0.8125, 0.0000), vec3(1.0000, 1.0000, 1.0000)),

    // Carpets, snow and misc blocks
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.0625, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.1250, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.2500, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.3750, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.6250, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.7500, 1.0000)),
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.8750, 1.0000)),

    // Grass path and farmland
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.9375, 1.0000)),

    // Fences and walls (post only)
    vec3[2](vec3(0.3750, 0.0000, 0.3750), vec3(0.6250, 1.0000, 0.6250)),
    vec3[2](vec3(0.3750, 0.0000, 0.3750), vec3(0.6250, 1.0000, 0.6250)),
    vec3[2](vec3(0.2500, 0.0000, 0.2500), vec3(0.7500, 1.0000, 0.7500)),

    // Lava
    vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 8.0/9.0, 1.0000)),

    // Torch
    vec3[2](vec3(0.4375, 0.0000, 0.4375), vec3(0.5625, 0.6250, 0.5625)),
    vec3[2](vec3(0.4375, 0.0000, 0.4375), vec3(0.5625, 0.6250, 0.5625)),
    vec3[2](vec3(0.4375, 0.0000, 0.4375), vec3(0.5625, 0.6250, 0.5625)),

    // Lanterns
    vec3[2](vec3(0.3125, 0.0000, 0.3125), vec3(0.6875, 0.4375, 0.6875)),
    vec3[2](vec3(0.3125, 0.0625, 0.3125), vec3(0.6875, 0.5000, 0.6875)),
    vec3[2](vec3(0.3125, 0.0000, 0.3125), vec3(0.6875, 0.4375, 0.6875)),
    vec3[2](vec3(0.3125, 0.0625, 0.3125), vec3(0.6875, 0.5000, 0.6875)),

    // End rods
    vec3[2](vec3(0.4375, 0.0000, 0.4375), vec3(0.5625, 1.0000, 0.5625)),
    vec3[2](vec3(0.0000, 0.4375, 0.4375), vec3(1.0000, 0.5625, 0.5625)),
    vec3[2](vec3(0.4375, 0.4375, 0.0000), vec3(0.5625, 0.5625, 1.0000)),

    // Beacon
    vec3[2](vec3(0.1875, 0.0000, 0.1875), vec3(0.8125, 0.8750, 0.8125))
);

const vec3[12][4] stairBounds = vec3[12][4](
    vec3[4](vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 0.5), vec3(-1.0), vec3(-1.0)),
    vec3[4](vec3(0.0, 0.0, 0.5), vec3(1.0, 1.0, 1.0), vec3(-1.0), vec3(-1.0)),
    vec3[4](vec3(0.5, 0.0, 0.0), vec3(1.0, 1.0, 1.0), vec3(-1.0), vec3(-1.0)),
    vec3[4](vec3(0.0, 0.0, 0.0), vec3(0.5, 1.0, 1.0), vec3(-1.0), vec3(-1.0)),
    vec3[4](vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 0.5), vec3(0.0, 0.0, 0.0), vec3(0.5, 1.0, 1.0)),
    vec3[4](vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 0.5), vec3(0.5, 0.0, 0.0), vec3(1.0, 1.0, 1.0)),
    vec3[4](vec3(0.0, 0.0, 0.5), vec3(1.0, 1.0, 1.0), vec3(0.0, 0.0, 0.0), vec3(0.5, 1.0, 1.0)),
    vec3[4](vec3(0.0, 0.0, 0.5), vec3(1.0, 1.0, 1.0), vec3(0.5, 0.0, 0.0), vec3(1.0, 1.0, 1.0)),
    vec3[4](vec3(0.0, 0.0, 0.0), vec3(0.5, 1.0, 0.5), vec3(-1.0), vec3(-1.0)),
    vec3[4](vec3(0.5, 0.0, 0.0), vec3(1.0, 1.0, 0.5), vec3(-1.0), vec3(-1.0)),
    vec3[4](vec3(0.0, 0.0, 0.5), vec3(0.5, 1.0, 1.0), vec3(-1.0), vec3(-1.0)),
    vec3[4](vec3(0.5, 0.0, 0.5), vec3(1.0, 1.0, 1.0), vec3(-1.0), vec3(-1.0))
);

bool IntersectAABB(vec3 pos, vec3 dir, vec3 minBounds, vec3 maxBounds, out float dist, inout vec3 hitNormal) {
    if(any(lessThan(minBounds, vec3(0.0)))) return false;
	vec3 minBoundsDist = (minBounds - pos) / dir;
	vec3 maxBoundsDist = (maxBounds - pos) / dir;

	vec3 minDists = min(minBoundsDist, maxBoundsDist);
	vec3 maxDists = max(minBoundsDist, maxBoundsDist);

	//* Check if no intersection
	if(minDists.x > maxDists.y
	|| minDists.x > maxDists.z
	|| minDists.y > maxDists.x
	|| minDists.y > maxDists.z
	|| minDists.z > maxDists.x
	|| minDists.z > maxDists.y) {
		return false;
	}
    // if(any(greaterThan(minDists,maxDists.yxx))||any(greaterThan(minDists,maxDists.zzx)))

	// Intersect
	vec3 positiveDir = step(0.0, dir);
	vec3 dists = mix(maxBoundsDist, minBoundsDist, positiveDir);
	     dists = max0(dists);

	if (dists.x > dists.y) {
		if (dists.x > dists.z) {
			dist = dists.x;
			hitNormal = vec3(-positiveDir.x * 2.0 + 1.0, 0.0, 0.0);
		} else {
			dist = dists.z;
			hitNormal = vec3(0.0, 0.0, -positiveDir.z * 2.0 + 1.0);
		}
	} else if (dists.y > dists.z) {
		dist = dists.y;
		hitNormal = vec3(0.0, -positiveDir.y * 2.0 + 1.0, 0.0);
	} else {
		dist = dists.z;
		hitNormal = vec3(0.0, 0.0, -positiveDir.z * 2.0 + 1.0);
	}

	/*
    dist = max(max(dists.x,dists.y),dists.z);
    hitNormal = (-positiveDir * 2.0 + 1.0) * float(equal(dists,vec3(dist)));
	*/

	// Check to make sure we're not intersecting something in the wrong direction
	return dist > 0.0;
}

vec4 getAlbedo(vec3 hitPos, vec3 hitNormal, vec4[2] voxel){
    int id = ExtractVoxelId(voxel);

    #ifdef IntersectCross
	if(id == 249 || id == 250) {
		vec2 pos1 = round(hitPos.xz);
		vec2 pos2 = floor(hitPos.xz);
		if(pos1.x > pos2.x && pos1.y > pos2.y) {
			if(hitNormal.z > 0.0) hitNormal = vec3(0.0,0.0,1.0);
			else hitNormal = vec3(1.0,0.0,0.0);
		}
		else if(pos1.x > pos2.x && pos1.y == pos2.y) {
			if(hitNormal.z < 0.0) hitNormal = vec3(0.0,0.0,-1.0);
			else hitNormal = vec3(1.0,0.0,0.0);
		}
		else if(pos1.x == pos2.x && pos1.y > pos2.y) {
			if(hitNormal.z < 0.0) hitNormal = vec3(-1.0,0.0,0.0);
			else hitNormal = vec3(0.0,0.0,1.0);
		}
		else {
			if(hitNormal.z > 0.0) hitNormal = vec3(-1.0,0.0,0.0);
			else hitNormal = vec3(0.0,0.0,-1.0);
		}
	}
    #endif

	// Figure out texture coordinates
	int   tileSize = ExtractVoxelTileSize(voxel);
	ivec2 tileOffs = ExtractVoxelTileIndex(voxel) * tileSize;

	ivec2 uv;
	if (abs(hitNormal.y) > abs(hitNormal.x) && abs(hitNormal.y) > abs(hitNormal.z)) {
		uv = ivec2(fract(hitPos.x) * tileSize, fract(hitPos.z * sign(hitNormal.y)) * tileSize);
	} else {
		uv = ivec2(fract(hitPos.x * sign(hitNormal.z) - hitPos.z * sign(hitNormal.x)) * tileSize, fract(-hitPos.y) * tileSize);
	}

	ivec2 atlasUV = tileOffs + uv;

    // Read textures
    return texelFetch(depthtex1, atlasUV, 0);
}

float IntersectPlane(vec3 origin, ivec3 index, vec3 direction, vec3 normal, out vec3 hitNormal) {
	vec3 point = vec3(0.5);
	vec3 relativeOrigin = origin - index;
    hitNormal = -normal * sign(dot(normal, direction));
    return clamp(dot(point - relativeOrigin, normal) / dot(direction, normal), -1.0, 9991999.0);
}

bool IntersectGrass(vec3 origin, ivec3 index, vec3 direction, out vec3 hitPos, inout vec3 hitNormal) {

	vec4[2] voxel = ReadVoxel(index);

    vec3 normal1;
    float dist1 = IntersectPlane(origin, index, direction, normalize(vec3(0.5, 0, 0.5)), normal1);

    vec3 normal2;
    float dist2 = IntersectPlane(origin, index, direction, normalize(vec3(0.5, 0, -0.5)), normal2);

    vec3 pos1 = origin + direction * dist1;
    if(vec3(floor(pos1)) != index || getAlbedo(pos1, normal1, voxel).a < 0.102) {
        dist1 = 9999999.;
    }
    vec3 pos2 = origin + direction * dist2;
    if(vec3(floor(pos2)) != index || getAlbedo(pos2, normal2, voxel).a < 0.102) {
        dist2 = 9999999.;
    }

    hitNormal = mix(normal2, normal1, float(dist1<dist2));
    float dist = min(dist1, dist2);
    hitPos = origin + direction * dist;

    return dist > 0.001 && vec3(floor(hitPos)) == index;
}

bool IntersectFence(vec3 origin, ivec3 index, vec3 direction, int id, out vec3 hitPos, inout vec3 hitNormal) {
	bool intersected;
	float intersectDist;
	vec3 intersectNormal;

	// Post
	intersected = IntersectAABB(origin - index, direction, vec3(0.375,0,0.375), vec3(0.625,1,0.625), intersectDist, intersectNormal);

	// Check connected directions
	int idEast  = ExtractVoxelId(ReadVoxel(index + ivec3(1,0,0)));
	int idWest  = ExtractVoxelId(ReadVoxel(index - ivec3(1,0,0)));
	int idSouth = ExtractVoxelId(ReadVoxel(index + ivec3(0,0,1)));
	int idNorth = ExtractVoxelId(ReadVoxel(index - ivec3(0,0,1)));

	bool east  = idEast  == 1 || idEast  == 2 || idEast == 9 || idEast == 10 || idEast == 12 || idEast == 22 || idEast == 23 || idEast == 25 || idEast == 50 || idEast  == (id == 64 ? 64 : 65) || idEast == 78 || (idEast >= 110 && idEast <= 129) || idEast == 200 || idEast == 201 || idEast == 202;
	bool west  = idWest  == 1 || idWest  == 2 || idWest == 8 || idWest == 11 || idWest == 13 || idWest == 21 || idWest == 24 || idWest == 26 || idWest == 51 || idWest  == (id == 64 ? 64 : 65) || idWest == 78 || (idWest >= 110 && idWest <= 129) || idWest == 200 || idWest == 201 || idWest == 202;
	bool south = idSouth  == 1 || idSouth  == 2 || idSouth == 6 || idSouth == 12 || idSouth == 13 || idSouth == 25 || idSouth == 26 || idSouth == 26 || idSouth == 52 || idSouth  == (id == 64 ? 64 : 65) || idSouth == 78 || (idSouth >= 110 && idSouth <= 129) || idSouth == 200 || idSouth == 201 || idSouth == 202;
	bool north = idNorth  == 1 || idNorth  == 2 || idNorth == 7 || idNorth == 10 || idNorth == 11 || idNorth == 19 || idNorth == 23 || idNorth == 24 || idNorth == 53 || idNorth  == (id == 64 ? 64 : 65) || idNorth == 78 || (idNorth >= 110 && idNorth <= 129) || idNorth == 200 || idNorth == 201 || idNorth == 202;

	// temp holders
	float tDist;
	vec3 tNormal;

	// East-west connection
	if (east || west) {
		// Upper bar
		vec3 xUpperMin = vec3(west ? 0.0 : 0.5, 0.75,   0.4375);
		vec3 xUpperMax = vec3(east ? 1.0 : 0.5, 0.9375, 0.5625);
		if (IntersectAABB(origin - index, direction, xUpperMin, xUpperMax, tDist, tNormal)) {
			if (!intersected || tDist < intersectDist) {
				intersectDist = tDist;
				intersectNormal = tNormal;
			}
			intersected = true;
		}

		// Lower bar
		vec3 xLowerMin = vec3(west ? 0.0 : 0.5, 0.375,  0.4375);
		vec3 xLowerMax = vec3(east ? 1.0 : 0.5, 0.5625, 0.5625);
		if (IntersectAABB(origin - index, direction, xLowerMin, xLowerMax, tDist, tNormal)) {
			if (!intersected || tDist < intersectDist) {
				intersectDist = tDist;
				intersectNormal = tNormal;
			}
			intersected = true;
		}
	}

	// North-south connection
	if (south || north) {
		// Upper bar
		vec3 zUpperMin = vec3(0.4375, 0.75,   north ? 0.0 : 0.5);
		vec3 zUpperMax = vec3(0.5625, 0.9375, south ? 1.0 : 0.5);
		if (IntersectAABB(origin - index, direction, zUpperMin, zUpperMax, tDist, tNormal)) {
			if (!intersected || tDist < intersectDist) {
				intersectDist = tDist;
				intersectNormal = tNormal;
			}
			intersected = true;
		}

		// Lower bar
		vec3 zLowerMin = vec3(0.4375, 0.375,  north ? 0.0 : 0.5);
		vec3 zLowerMax = vec3(0.5625, 0.5625, south ? 1.0 : 0.5);
		if (IntersectAABB(origin - index, direction, zLowerMin, zLowerMax, tDist, tNormal)) {
			if (!intersected || tDist < intersectDist) {
				intersectDist = tDist;
				intersectNormal = tNormal;
			}
			intersected = true;
		}
	}

	if (intersected) {
		hitPos = intersectDist * direction + origin;
		hitNormal = intersectNormal;
	}

	return intersected;
}


bool IntersectWall(vec3 origin, ivec3 index, vec3 direction, out vec3 hitPos, inout vec3 hitNormal) {
	bool intersected = false;
	float intersectDist;
	vec3 intersectNormal;

	// Check connected directions
	int idEast  = ExtractVoxelId(ReadVoxel(index + ivec3(1,0,0)));
	int idWest  = ExtractVoxelId(ReadVoxel(index - ivec3(1,0,0)));
	int idSouth = ExtractVoxelId(ReadVoxel(index + ivec3(0,0,1)));
	int idNorth = ExtractVoxelId(ReadVoxel(index - ivec3(0,0,1)));
	int idUp    = ExtractVoxelId(ReadVoxel(index + ivec3(0,1,0)));

	bool east  = idEast  == 1 || idEast  == 2 || idEast == 9 || idEast == 10 || idEast == 12 || idEast == 22 || idEast == 23 || idEast == 25 || idEast == 50 || idEast == 66 || idEast == 78 || (idEast >= 110 && idEast <= 129) || idEast == 200 || idEast == 201 || idEast == 202;
	bool west  = idWest  == 1 || idWest  == 2 || idWest == 8 || idWest == 11 || idWest == 13 || idWest == 21 || idWest == 24 || idWest == 26 || idWest == 51 || idWest == 66 || idWest == 78 || (idWest >= 110 && idWest <= 129) || idWest == 200 || idWest == 201 || idWest == 202;
	bool south = idSouth  == 1 || idSouth  == 2 || idSouth == 6 || idSouth == 12 || idSouth == 13 || idSouth == 25 || idSouth == 26 || idSouth == 26 || idSouth == 52 || idSouth == 66 || idSouth == 78 || (idSouth >= 110 && idSouth <= 129) || idSouth == 200 || idSouth == 201 || idSouth == 202;
	bool north = idNorth  == 1 || idNorth  == 2 || idNorth == 7 || idNorth == 10 || idNorth == 11 || idNorth == 19 || idNorth == 23 || idNorth == 24 || idNorth == 53 || idNorth == 66 || idNorth == 78 || (idNorth >= 110 && idNorth <= 129) || idNorth == 200 || idNorth == 201 || idNorth == 202;
	bool up    = idUp  == 1 || idUp  == 2 || (idUp >= 5 && idUp <= 17) || idUp  == 64 || idUp == 65 || idUp == 66 || idUp == 78 || (idUp >= 110 && idUp <= 129) || idUp == 200 || idUp == 201 || idUp == 202;

	// Post
	if (!((east && west && !south && !north) || (!east && !west && south && north)) || up) {
		intersected = IntersectAABB(origin - index, direction, vec3(0.25,0,0.25), vec3(0.75,1,0.75), intersectDist, intersectNormal);
	}

	// temp holders
	float tDist;
	vec3 tNormal;

	// East-west connection
	if (east || west) {
		vec3 minBounds = vec3(west ? 0.0 : 0.5, 0.0,   0.3125);
		vec3 maxBounds = vec3(east ? 1.0 : 0.5, 0.875, 0.6875);
		if (IntersectAABB(origin - index, direction, minBounds, maxBounds, tDist, tNormal)) {
			if (!intersected || tDist < intersectDist) {
				intersectDist = tDist;
				intersectNormal = tNormal;
				intersected = true;
			}
		}
	}

	// North-south connection
	if (south || north) {
		vec3 minBounds = vec3(0.3125, 0.0,   north ? 0.0 : 0.5);
		vec3 maxBounds = vec3(0.6875, 0.875, south ? 1.0 : 0.5);
		if (IntersectAABB(origin - index, direction, minBounds, maxBounds, tDist, tNormal)) {
			if (!intersected || tDist < intersectDist) {
				intersectDist = tDist;
				intersectNormal = tNormal;
				intersected = true;
			}
		}
	}

	if (intersected) {
		hitPos = intersectDist * direction + origin;
		hitNormal = intersectNormal;
	}

	return intersected;
}

bool IntersectAnvil(vec3 origin, ivec3 index, vec3 direction, int dataValue, out vec3 hitPos, inout vec3 hitNormal) {
	bool intersected = false;
	float intersectDist;
	vec3 intersectNormal;

	int facing = dataValue % 2;

	// Base
	intersected = IntersectAABB(origin - index, direction, vec3(0.125,0,0.125), vec3(0.875,0.25,0.875), intersectDist, intersectNormal);

	// temp holders
	float tDist;
	vec3 tNormal;

	vec3 minBounds = facing == 0 ? vec3(0.25, 0.25,   0.1875) : vec3(0.1875, 0.25,   0.25);
	vec3 maxBounds = facing == 0 ? vec3(0.75, 0.3125, 0.8125) : vec3(0.8125, 0.3125, 0.75);
	if (IntersectAABB(origin - index, direction, minBounds, maxBounds, tDist, tNormal)) {
		if (!intersected || tDist < intersectDist) {
			intersectDist = tDist;
			intersectNormal = tNormal;
			intersected = true;
		}
	}

	minBounds = facing == 0 ? vec3(0.375, 0.3125, 0.25) : vec3(0.25, 0.3125, 0.375);
	maxBounds = facing == 0 ? vec3(0.625, 0.625,  0.75) : vec3(0.75, 0.625,  0.625);
	if (IntersectAABB(origin - index, direction, minBounds, maxBounds, tDist, tNormal)) {
		if (!intersected || tDist < intersectDist) {
			intersectDist = tDist;
			intersectNormal = tNormal;
			intersected = true;
		}
	}

	minBounds = facing == 0 ? vec3(0.1875, 0.625, 0.0) : vec3(0.0, 0.625, 0.1875);
	maxBounds = facing == 0 ? vec3(0.8125, 1.0,   1.0) : vec3(1.0, 1.0,   0.8125);
	if (IntersectAABB(origin - index, direction, minBounds, maxBounds, tDist, tNormal)) {
		if (!intersected || tDist < intersectDist) {
			intersectDist = tDist;
			intersectNormal = tNormal;
			intersected = true;
		}
	}

	if (intersected) {
		hitPos = intersectDist * direction + origin;
		hitNormal = intersectNormal;
	}

	return intersected;
}

bool IntersectBlock(vec3 origin, ivec3 index, vec3 direction, out vec3 hitPos, inout vec3 hitNormal) {
	vec3 minBoundsDist = (      index - origin) / direction;
	vec3 maxBoundsDist = (1.0 + index - origin) / direction;

	vec3 positiveDir = step(0.0, direction);
	vec3 dists       = mix(maxBoundsDist, minBoundsDist, positiveDir);

	if (dists.x > dists.y) {
		if (dists.x > dists.z) {
			hitPos = dists.x * direction + origin;
			hitNormal = vec3(-positiveDir.x * 2.0 + 1.0, 0.0, 0.0);
		} else {
			hitPos = dists.z * direction + origin;
			hitNormal = vec3(0.0, 0.0, -positiveDir.z * 2.0 + 1.0);
		}
	} else if (dists.y > dists.z) {
		hitPos = dists.y * direction + origin;
		hitNormal = vec3(0.0, -positiveDir.y * 2.0 + 1.0, 0.0);
	} else {
		hitPos = dists.z * direction + origin;
		hitNormal = vec3(0.0, 0.0, -positiveDir.z * 2.0 + 1.0);
	}

	return true;
}

bool IntersectGenericEmitter(vec3 origin, ivec3 index, vec3 direction, out vec3 hitPos, inout vec3 hitNormal) {
	vec3 r0 = origin - index; // Origin relative to voxel
	vec3 rd = direction; // Ray direction
	vec3 s0 = vec3(0.5, 0.6, 0.5); // Sphere center relative to voxel
	float sr = 0.42; // Sphere radius

    float a = dot(rd, rd);
    vec3 s0_r0 = r0 - s0;
    float b = 2.0 * dot(rd, s0_r0);
    float c = dot(s0_r0, s0_r0) - (sr * sr);
    if (b*b - 4.0*a*c < 0.0) {
        return false;
    }
    float dist = (-b - sqrt((b*b) - 4.0*a*c))/(2.0*a);
	hitPos = dist * direction + origin;
	return true;
}

bool IntersectVoxel(vec3 origin, ivec3 index, vec3 direction, int id, out vec3 hitPos, inout vec3 hitNormal) {
	// default value
	hitPos = origin;

	/*
	if (id == 64 || id == 65) {
		return IntersectFence(origin, index, direction, id, hitPos, hitNormal);
	}
    

    
	if (id == 66) {
		return IntersectWall(origin, index, direction, hitPos, hitNormal);
    }
    

    
	if (id == 130 || id == 131) {
		return IntersectAnvil(origin, index, direction, id-129, hitPos, hitNormal);
	}
	*/

    
	if (id == 249 || id == 250) {
		return IntersectGrass(origin, index, direction, hitPos, hitNormal);
	}
	

	else if(id >= 4 && id <= 78) {

		float dist;
		bool hit = IntersectAABB(origin - index, direction, bounds[id-4][0], bounds[id-4][1], dist, hitNormal);

        


		hitPos = origin + direction * dist;
		return hit;
	}

	else if (IsSphericalEmissiveId(id)) {
		return IntersectGenericEmitter(origin, index, direction, hitPos, hitNormal);
	} else {

		return IntersectBlock(origin, index, direction, hitPos, hitNormal);
	}
}

bool IntersectVoxel(vec3 origin, ivec3 index, vec3 direction, int id, out vec3 hitPos, inout vec3 hitNormal, vec4[2] voxel, bool depthHit, inout vec3 accColor) {
	bool hit = IntersectVoxel(origin, index, direction, id, hitPos, hitNormal);
	if((id == 3 || id == 200) && depthHit) return false;
	if(hit && !IsEmissiveId(id) && id != 130 && id != 131) {
        vec4 albedo = getAlbedo(hitPos, hitNormal, voxel); // Albedo
		float isTranslucent = float(id == 201 || id == 202);

		accColor *= mix(vec3(1.0), (albedo.rgb) * sRGBtoAP1, isTranslucent);


			return (mix(albedo.a + float(id == 2), 0.0, isTranslucent)) > 0.102;

	}
	return hit;
}

bool RaytraceVoxel(vec3 origin, ivec3 originIndex, vec3 direction, bool transmit, const int maxSteps, out vec4[2] voxel, out vec3 hitPos, out vec3 hitNormal, out vec3 accumulateColor) {

	accumulateColor = vec3(1.0);


	voxel = ReadVoxel(originIndex);

	int pid = ExtractVoxelId(voxel);
    bool hit = false;

	if ((pid > 0  && pid < 251) && !transmit) {
		hit = IntersectVoxel(origin, originIndex, direction, pid, hitPos, hitNormal, voxel, true, accumulateColor);
	}


	ivec3 voxelIndex = originIndex;
	vec3 deltaDist;
	vec3 next;
	ivec3 deltaSign;
	for (int axis = 0; axis < 3; ++axis) {
		deltaDist[axis] = length(direction / direction[axis]);
		if (direction[axis] < 0.0) {
			deltaSign[axis] = -1;
			next[axis] = (origin[axis] - voxelIndex[axis]) * deltaDist[axis];
		} else {
			deltaSign[axis] = 1;
			next[axis] = (voxelIndex[axis] + 1.0 - origin[axis]) * deltaDist[axis];
		}
	}

	for (int i = 0; i < maxSteps && !hit; ++i) {
		if (next.x > next.y) {
			if (next.y > next.z) {
				next.z       += deltaDist.z;
				voxelIndex.z += deltaSign.z;
				hitNormal     = vec3(0, 0, -deltaSign.z);
			} else {
				next.y       += deltaDist.y;
				voxelIndex.y += deltaSign.y;
				hitNormal     = vec3(0, -deltaSign.y, 0);
			}
		} else if (next.x > next.z) {
			next.z       += deltaDist.z;
			voxelIndex.z += deltaSign.z;
			hitNormal     = vec3(0, 0, -deltaSign.z);
		} else {
			next.x       += deltaDist.x;
			voxelIndex.x += deltaSign.x;
			hitNormal     = vec3(-deltaSign.x, 0, 0);
		}

		if (!IsInVoxelizationVolume(voxelIndex)) { break; }

		voxel  = ReadVoxel(voxelIndex);
		int id = ExtractVoxelId(voxel);


        
		if(id > 0 && id < 251) {
			hit = IntersectVoxel(origin, voxelIndex, direction, id, hitPos, hitNormal, voxel, false, accumulateColor);
		}

	}
	;

	return hit;
}

bool RaymarchVoxelFloodfill(sampler2D tex, vec3 origin, ivec3 originIndex, vec3 direction, bool transmit, const int maxSteps, out vec3 accumulateColor) {

	accumulateColor = vec3(0.0);
	vec3 hitPos,hitNormal;


	vec4[2] voxel = ReadVoxel(originIndex);

	int pid = ExtractVoxelId(voxel);
    bool hit = false;

	if ((pid > 0  && pid < 251) && !transmit) {
		hit = IntersectVoxel(origin, originIndex, direction, pid, hitPos, hitNormal, voxel, true, accumulateColor);
	}


	ivec3 voxelIndex = originIndex;
	vec3 deltaDist;
	vec3 next;
	ivec3 deltaSign;
	for (int axis = 0; axis < 3; ++axis) {
		deltaDist[axis] = length(direction / direction[axis]);
		if (direction[axis] < 0.0) {
			deltaSign[axis] = -1;
			next[axis] = (origin[axis] - voxelIndex[axis]) * deltaDist[axis];
		} else {
			deltaSign[axis] = 1;
			next[axis] = (voxelIndex[axis] + 1.0 - origin[axis]) * deltaDist[axis];
		}
	}

	for (int i = 0; i < maxSteps && !hit; ++i) {
		if (next.x > next.y) {
			if (next.y > next.z) {
				next.z       += deltaDist.z;
				voxelIndex.z += deltaSign.z;
				hitNormal     = vec3(0, 0, -deltaSign.z);
			} else {
				next.y       += deltaDist.y;
				voxelIndex.y += deltaSign.y;
				hitNormal     = vec3(0, -deltaSign.y, 0);
			}
		} else if (next.x > next.z) {
			next.z       += deltaDist.z;
			voxelIndex.z += deltaSign.z;
			hitNormal     = vec3(0, 0, -deltaSign.z);
		} else {
			next.x       += deltaDist.x;
			voxelIndex.x += deltaSign.x;
			hitNormal     = vec3(-deltaSign.x, 0, 0);
		}

		if (!IsInVoxelizationVolume(voxelIndex)) { break; }

		voxel  = ReadVoxel(voxelIndex);
		int id = ExtractVoxelId(voxel);
accumulateColor+= texelFetch(tex, GetVoxelStoragePos(ivec3(floor(voxelIndex))), 0).rgb;

        
		if(id > 0 && id < 251) {
			hit = IntersectVoxel(origin, voxelIndex, direction, id, hitPos, hitNormal, voxel, false, accumulateColor);
		}

	}
	;

	return hit;
}

bool RaytraceVoxelShadows(vec3 origin, ivec3 originIndex, vec3 direction, bool transmit, const int maxSteps) {

	vec3 accumulateColor = vec3(1.0);
	vec4[2] voxel;
	vec3 hitPos,hitNormal;

	voxel = ReadVoxel(originIndex);

	int pid = ExtractVoxelId(voxel);
    bool hit = false;
    #ifdef IntersectCross
	if ((pid > 0  && pid < 251) && !transmit) {
		hit = IntersectVoxel(origin, originIndex, direction, pid, hitPos, hitNormal, voxel, true, accumulateColor);
	}
    #else
    if ((pid > 0  && pid < 249) && !transmit) {
		hit = IntersectVoxel(origin, originIndex, direction, pid, hitPos, hitNormal, voxel, true, accumulateColor);
	}
    #endif

	ivec3 voxelIndex = originIndex;
	vec3 deltaDist;
	vec3 next;
	ivec3 deltaSign;
	for (int axis = 0; axis < 3; ++axis) {
		deltaDist[axis] = length(direction / direction[axis]);
		if (direction[axis] < 0.0) {
			deltaSign[axis] = -1;
			next[axis] = (origin[axis] - voxelIndex[axis]) * deltaDist[axis];
		} else {
			deltaSign[axis] = 1;
			next[axis] = (voxelIndex[axis] + 1.0 - origin[axis]) * deltaDist[axis];
		}
	}

	for (int i = 0; i < maxSteps && !hit; ++i) {
		if (next.x > next.y) {
			if (next.y > next.z) {
				next.z       += deltaDist.z;
				voxelIndex.z += deltaSign.z;
				hitNormal     = vec3(0, 0, -deltaSign.z);
			} else {
				next.y       += deltaDist.y;
				voxelIndex.y += deltaSign.y;
				hitNormal     = vec3(0, -deltaSign.y, 0);
			}
		} else if (next.x > next.z) {
			next.z       += deltaDist.z;
			voxelIndex.z += deltaSign.z;
			hitNormal     = vec3(0, 0, -deltaSign.z);
		} else {
			next.x       += deltaDist.x;
			voxelIndex.x += deltaSign.x;
			hitNormal     = vec3(-deltaSign.x, 0, 0);
		}

		if (!IsInVoxelizationVolume(voxelIndex)) { break; }

		voxel  = ReadVoxel(voxelIndex);
		int id = ExtractVoxelId(voxel);


        #ifdef IntersectCross
		if(id > 0 && id < 251 && !IsSphericalEmissiveId(id)) {
			hit = IntersectVoxel(origin, voxelIndex, direction, id, hitPos, hitNormal, voxel, false, accumulateColor);
		}
        #else
		if(id > 0 && id < 249 && !IsSphericalEmissiveId(id)) {
			hit = IntersectVoxel(origin, voxelIndex, direction, id, hitPos, hitNormal, voxel, false, accumulateColor);
		}
        #endif
	}

	return hit;
}

vec3 RaytraceVoxelShadows2(vec3 origin, ivec3 originIndex, vec3 direction, bool transmit, const int maxSteps) {

	vec3 accumulateColor = vec3(1.0);
	vec4[2] voxel;
	vec3 hitPos,hitNormal;

	voxel = ReadVoxel(originIndex);

	int pid = ExtractVoxelId(voxel);
    bool hit = false;


	ivec3 voxelIndex = originIndex;
	vec3 deltaDist;
	vec3 next;
	ivec3 deltaSign;
	for (int axis = 0; axis < 3; ++axis) {
		deltaDist[axis] = length(direction / direction[axis]);
		if (direction[axis] < 0.0) {
			deltaSign[axis] = -1;
			next[axis] = (origin[axis] - voxelIndex[axis]) * deltaDist[axis];
		} else {
			deltaSign[axis] = 1;
			next[axis] = (voxelIndex[axis] + 1.0 - origin[axis]) * deltaDist[axis];
		}
	}

	for (int i = 0; i < maxSteps && !hit; ++i) {
		if (next.x > next.y) {
			if (next.y > next.z) {
				next.z       += deltaDist.z;
				voxelIndex.z += deltaSign.z;
				hitNormal     = vec3(0, 0, -deltaSign.z);
			} else {
				next.y       += deltaDist.y;
				voxelIndex.y += deltaSign.y;
				hitNormal     = vec3(0, -deltaSign.y, 0);
			}
		} else if (next.x > next.z) {
			next.z       += deltaDist.z;
			voxelIndex.z += deltaSign.z;
			hitNormal     = vec3(0, 0, -deltaSign.z);
		} else {
			next.x       += deltaDist.x;
			voxelIndex.x += deltaSign.x;
			hitNormal     = vec3(-deltaSign.x, 0, 0);
		}

		if (!IsInVoxelizationVolume(voxelIndex)) { break; }

		voxel  = ReadVoxel(voxelIndex);
		int id = ExtractVoxelId(voxel);
				vec3 tint = ExtractVoxelTint(voxel);
		float isTranslucent = float(id == 201 || id == 202);

        
		if(id > 0 && id < 251  && !IsSphericalEmissiveId(id)) {
			accumulateColor *= mix(vec3(0.0), tint, isTranslucent);
			hit = !((id >= 64 && id <=101) || (id >= 31 && id <= 54) || id==200 || id == 201);
		}

        
	}

	return hit ? accumulateColor : vec3(1.0);
}
uniform sampler2D colortex15;

void getMaterial(inout material mat, vec3 position, vec3 normal, vec4[2] voxel) {
    int id = ExtractVoxelId(voxel);

   
	if(id == 249 || id == 250) {
		vec2 pos1 = round(position.xz);
		vec2 pos2 = floor(position.xz);
		if(pos1.x > pos2.x && pos1.y > pos2.y) {
			if(normal.z > 0.0) normal = vec3(0.0,0.0,1.0);
			else normal = vec3(1.0,0.0,0.0);
		}
		else if(pos1.x > pos2.x && pos1.y == pos2.y) {
			if(normal.z < 0.0) normal = vec3(0.0,0.0,-1.0);
			else normal = vec3(1.0,0.0,0.0);
		}
		else if(pos1.x == pos2.x && pos1.y > pos2.y) {
			if(normal.z < 0.0) normal = vec3(-1.0,0.0,0.0);
			else normal = vec3(0.0,0.0,1.0);
		}
		else {
			if(normal.z > 0.0) normal = vec3(-1.0,0.0,0.0);
			else normal = vec3(0.0,0.0,-1.0);
		}
	}
    

    // Figure out texture coordinates
	int   tileSize = ExtractVoxelTileSize(voxel);
	ivec2 tileOffs = ExtractVoxelTileIndex(voxel) * tileSize;

	ivec2 uv;
	mat3 tbn;
	if (abs(normal.y) > abs(normal.x) && abs(normal.y) > abs(normal.z)) {
		uv = ivec2(fract(position.x) * tileSize, fract(position.z * sign(normal.y)) * tileSize);
		tbn = mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, sign(normal.y)), normal);
	} else {
		uv = ivec2(fract(position.x * sign(normal.z) - position.z * sign(normal.x)) * tileSize, fract(-position.y) * tileSize);
		tbn = mat3(vec3(sign(normal.z), 0.0, -sign(normal.x)), vec3(0.0, -1.0, 0.0), normal);
	}

    ivec2 atlasUV = tileOffs + uv;

    

    // Read textures
    vec4 albedoTex = texelFetch(depthtex1, atlasUV, 0);
    vec4 normalTex = texelFetch(depthtex2, atlasUV, 0);
    vec4 specularTex = texelFetch(colortex15, atlasUV, 0);


    albedoTex.rgb = (albedoTex.rgb) * sRGBtoAP1;
    vec3 normals = normalTex.xyz*2.0-1.0;
    	 normals = normalize(vec3(normals.xy, sqrt(1.0 - dot(normals.xy, normals.xy))));

    mat.albedo =  IsSphericalEmissiveId(id) ? ExtractVoxelTint(voxel) * sRGBtoAP1 : mix(albedoTex.rgb, albedoTex.rgb * ExtractVoxelTint(voxel), float(id == 2 || id == 3  || id == 250));
    mat.normal = tbn * normals;
    mat.emission = IsSphericalEmissiveId(id) ? 400. : (specularTex.a == 1.0 ? 0.0 : specularTex.a) * 4000.;
	
}
