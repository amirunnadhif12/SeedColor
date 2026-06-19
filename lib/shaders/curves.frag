#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform sampler2D uLutTexture; // 256x1 texture: R=Red, G=Green, B=Blue, A=RGB curve

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord() / uSize;
    vec4 color = texture(uTexture, uv);

    // Apply R, G, B curves from LUT
    float r = texture(uLutTexture, vec2(color.r, 0.5)).r;
    float g = texture(uLutTexture, vec2(color.g, 0.5)).g;
    float b = texture(uLutTexture, vec2(color.b, 0.5)).b;

    // Apply combined RGB curve (stored in alpha/A channel of LUT)
    r = texture(uLutTexture, vec2(r, 0.5)).a;
    g = texture(uLutTexture, vec2(g, 0.5)).a;
    b = texture(uLutTexture, vec2(b, 0.5)).a;

    fragColor = vec4(clamp(vec3(r, g, b), 0.0, 1.0), color.a);
}
