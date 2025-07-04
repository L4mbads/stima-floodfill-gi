#version 150

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

in vec2 vaUV0;
in vec3 vaPosition;

out vec2 texcoord;

void main() {
	gl_Position = projectionMatrix * (modelViewMatrix * vec4(vaPosition, 1.0));
	//gl_Position.xy = (gl_Position.xy*0.5+0.5)*TAAUres*2.0-1.0;
	texcoord    = vaUV0;
}