#version 460 core
#extension GL_NV_gpu_shader5 : require
#extension GL_ARB_bindless_texture : enable

in vec2 TexCoord;
layout(binding = 0) uniform sampler2D tex;

out vec4 FragColor;
flat in sampler2D Tex;

void main()
{
    FragColor = texture(Tex, TexCoord);
}
