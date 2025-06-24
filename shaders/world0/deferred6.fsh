#version 430
#extension GL_ARB_explicit_attrib_location : enable

in vec2 texcoord;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D depthtex0;
uniform sampler2D shadowcolor0;
uniform int frameCounter;
uniform vec2 resolution;
uniform vec2 pixelSize;


#include "/lib/Settings.glsl"
#include "/lib/Random.glsl"
#include "/lib/Encoding.glsl"
#include "/lib/Projection.glsl"
#include "/lib/Atrous.glsl"


/*RENDERTARGETS:7,8*/
layout(location = 0) out vec4 colortex7Out;
layout(location = 1) out vec4 colortex8Out;


void main() {
if(clamp(texcoord, vec2(0.0), vec2(TAAUres)) != texcoord) return;
	float depth = texture(depthtex0, texcoord/TAAUres).r;
	vec4 currData = texture(colortex7, texcoord);
	colortex8Out = texture(colortex8, texcoord);

	if(depth >= 1.0) {colortex7Out = currData; return;}


	float accumulation = texture(colortex6, texcoord).b;


	colortex7Out = atrous(colortex7, colortex8,  colortex5, depth, texcoord, 3, false, accumulation, colortex8Out.rgb);


	
}
