#ifdef VoxelizationFix
bool IsInVoxelizationVolume(ivec3 voxelIndex) {
	const int xzRadiusBlocks = int(MC_SHADOW_QUALITY * shadowMapResolution) / 32;
	const ivec3 lo = ivec3(-xzRadiusBlocks    , clamp(cameraPosition.y - VoxelLowerBound, -64, 271),-xzRadiusBlocks    );
	const ivec3 hi = ivec3( xzRadiusBlocks - 1, clamp(cameraPosition.y + VoxelUpperBound,  63, 319), xzRadiusBlocks - 1);

	return clamp(voxelIndex, lo, hi) == voxelIndex;
}
#else
bool IsInVoxelizationVolume(ivec3 voxelIndex) {
	const int xzRadiusBlocks = int(MC_SHADOW_QUALITY * shadowMapResolution) / 32;
	const ivec3 lo = ivec3(-xzRadiusBlocks    , -64,-xzRadiusBlocks    );
	const ivec3 hi = ivec3( xzRadiusBlocks - 1, 384, xzRadiusBlocks - 1);

	return clamp(voxelIndex, lo, hi) == voxelIndex;
}
#endif

vec3 SceneSpaceToVoxelSpace(vec3 scenePosition) {
	scenePosition.xz += fract(cameraPosition.xz);
	scenePosition.y  += cameraPosition.y;
	return scenePosition;
}
vec3 VoxelSpaceToSceneSpace(vec3 voxelPosition) {
	voxelPosition.xz -= fract(cameraPosition.xz);
	voxelPosition.y  -= cameraPosition.y;
	return voxelPosition;
}
vec3 WorldSpaceToVoxelSpace(vec3 worldPosition) {
	worldPosition.xz -= floor(cameraPosition.xz);
	return worldPosition;
}

vec3 VoxelSpaceToWorldSpace(vec3 voxelPosition) {
	voxelPosition.xz += floor(cameraPosition.xz);
	return voxelPosition;
}

ivec2 GetVoxelStoragePos(ivec3 voxelIndex) { // in pixels/texels
    int offset = (320 - int(cameraPosition.y)) / 2 - 64;
	return (voxelIndex.xz + (int(MC_SHADOW_QUALITY * shadowMapResolution) / 32)) * ivec2(8, 16) + ivec2((voxelIndex.y + offset) / 16, (voxelIndex.y + offset) % 16);
}

ivec2 GetPreviousVoxelStoragePos(ivec3 voxelIndex, float py) { // in pixels/texels
    int offset = (320 - int(cameraPosition.y + floor(cameraPosition.y) - floor(py))) / 2 - 64;
	return (voxelIndex.xz + (int(MC_SHADOW_QUALITY * shadowMapResolution) / 32)) * ivec2(8, 16) + ivec2((voxelIndex.y + offset) / 16, (voxelIndex.y + offset) % 16);
}

ivec3 StoragePosToVoxelSpace(ivec2 storagePos) {
	int offset = (320 - int(cameraPosition.y)) / 2 - 64;
	ivec2 layerPos = storagePos % ivec2(8, 16);
	int y = (layerPos.x * 16 + layerPos.y) - offset;
	ivec2 xz = storagePos / ivec2(8, 16) - int(shadowMapResolution) / 32;
	return ivec3(xz.x, y, xz.y);
}


vec4[2] ReadVoxel(ivec3 voxelPosition) {
	ivec2 storagePos = GetVoxelStoragePos(voxelPosition);

	uvec2 data = texelFetch(shadowcolor1, storagePos, 0).xy;

	return vec4[2](unpackUnorm4x8(data.x), unpackUnorm4x8(data.y));
}


float PackUnorm2x4(vec2 xy) {
	return dot(floor(15.0 * xy + 0.5), vec2(1.0 / 255.0, 16.0 / 255.0));
}

vec2 UnpackUnorm2x4(float pack) {
	vec2 xy; xy.x = modf(pack * 255.0 / 16.0, xy.y);
	return xy * vec2(16.0 / 15.0, 1.0 / 15.0);
}

void SetVoxelTint(inout vec4[2] voxel, vec3 tint) {
	voxel[0].rgb = tint;
}
void SetVoxelId(inout vec4[2] voxel, int id) {
	voxel[0].a = id / 255.0;
}
void SetVoxelTileSize(inout vec4[2] voxel, vec2 tileSize) {
	voxel[1].x = clamp01(log2(max(tileSize.x, tileSize.y)) / 15.0);
}
void SetVoxelTileIndex(inout vec4[2] voxel, ivec2 tileIndex) {
	voxel[1].yzw = vec3(PackUnorm2x4(floor(tileIndex / 256.0) / 15.0), fract(tileIndex / 256.0) * 256.0 / 255.0);
}

vec3 ExtractVoxelTint(vec4[2] voxel) {
	return voxel[0].rgb;
}
int ExtractVoxelId(vec4[2] voxel) {
	return int(0.5 + 255.0 * voxel[0].a);
}
int ExtractVoxelTileSize(vec4[2] voxel) {
	return int(exp2(floor(voxel[1].x * 15.0 + 0.5)));
}
ivec2 ExtractVoxelTileIndex(vec4[2] voxel) {
	return ivec2(256.0 * 15.0 * UnpackUnorm2x4(voxel[1].y) + 255.0 * voxel[1].zw);
}