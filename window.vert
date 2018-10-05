#version 460 core
#extension GL_ARB_bindless_texture : enable

layout(std140) uniform;
layout(std430) buffer;

layout(binding = 0) uniform ScreenBlock {
	float width;
	float height;
	mat4 matrix;
} screen;

layout(binding = 1) uniform WindowBlock {
	vec4[6] rect;
} window;

const vec2 texPos[6] = vec2[] (
    vec2(0, 0),
    vec2(0, 1),
    vec2(1, 1),

    vec2(0, 0),
    vec2(1, 1),
    vec2(1, 0)
);

out vec2 TexCoord;

void main() {
    vec4 vertPos = window.rect[gl_VertexID];
	vec2 texPos = texPos[gl_VertexID];
    gl_Position = screen.matrix * vertPos;
	TexCoord = texPos;
}
