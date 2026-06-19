#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform vec3 uShadowsColor;     // Shadows RGB tint color (default [0,0,0])
uniform vec3 uMidtonesColor;    // Midtones RGB tint color (default [0,0,0])
uniform vec3 uHighlightsColor;  // Highlights RGB tint color (default [0,0,0])
uniform float uBlending;        // Blending factor (0.0 to 1.0)
uniform float uBalance;         // Balance factor (-1.0 to 1.0)

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord() / uSize;
    vec4 color = texture(uTexture, uv);

    float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));

    // 1. Balance power shift
    float balancedLuma = luma;
    if (uBalance > 0.0) {
        balancedLuma = pow(luma, 1.0 / (1.0 + uBalance * 0.5));
    } else if (uBalance < 0.0) {
        balancedLuma = pow(luma, 1.0 - uBalance * 0.5);
    }

    // 2. Shadows/Midtones/Highlights weights with blending
    float blend = uBlending; // 0.0 to 1.0
    float sEnd = mix(0.25, 0.5, blend);
    float hStart = mix(0.75, 0.5, blend);

    float wShadow = smoothstep(sEnd, 0.0, balancedLuma);
    float wHighlight = smoothstep(hStart, 1.0, balancedLuma);
    float wMidtone = max(0.0, 1.0 - wShadow - wHighlight);

    // 3. Apply color grading tints
    color.rgb += uShadowsColor * wShadow * (1.0 - color.rgb) * 0.5;
    color.rgb += uMidtonesColor * wMidtone * (1.0 - color.rgb) * 0.5;
    color.rgb += uHighlightsColor * wHighlight * (1.0 - color.rgb) * 0.5;

    fragColor = vec4(clamp(color.rgb, 0.0, 1.0), color.a);
}
