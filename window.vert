#version 460 core
#extension GL_NV_gpu_shader5 : require
#extension GL_ARB_bindless_texture : enable

layout(std140) uniform;
layout(std430) buffer;

layout(binding = 0) uniform ScreenBlock {
	float width;
	float height;
	mat4 matrix;
} screen;

layout(binding = 1) buffer WindowBlock {
	sampler2D[9216] tex;
	vec4[9216][6] rect;
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
flat out sampler2D Tex;

void main() {
    vec4 vertPos = window.rect[gl_InstanceID][gl_VertexID];
	vec2 texPos = texPos[gl_VertexID];
    gl_Position = screen.matrix * vertPos;
	TexCoord = texPos;
	Tex = window.tex[gl_InstanceID];
}
