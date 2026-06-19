#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform float uExposure;   // -5.0 to 5.0
uniform float uContrast;   // -100.0 to 100.0
uniform float uHighlights; // -100.0 to 100.0
uniform float uShadows;    // -100.0 to 100.0
uniform float uWhites;     // -100.0 to 100.0
uniform float uBlacks;     // -100.0 to 100.0

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord() / uSize;
    vec4 color = texture(uTexture, uv);
    
    // 1. Exposure
    color.rgb *= pow(2.0, uExposure);
    
    // 2. Contrast
    float contrastFactor = (uContrast + 100.0) / 100.0;
    color.rgb = (color.rgb - vec3(0.5)) * contrastFactor + vec3(0.5);
    
    // 3. Highlights & Shadows
    float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    float shadowWeight = smoothstep(0.6, 0.0, luma);
    float highlightWeight = smoothstep(0.4, 1.0, luma);
    
    if (uShadows > 0.0) {
        color.rgb += uShadows * 0.003 * shadowWeight * (1.0 - color.rgb);
    } else {
        color.rgb += uShadows * 0.003 * shadowWeight * color.rgb;
    }
    
    if (uHighlights > 0.0) {
        color.rgb += uHighlights * 0.003 * highlightWeight * (1.0 - color.rgb);
    } else {
        color.rgb += uHighlights * 0.003 * highlightWeight * color.rgb;
    }
    
    // Recalculate luma for Whites & Blacks
    luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    float whiteWeight = pow(luma, 3.0);
    float blackWeight = pow(1.0 - luma, 3.0);
    
    if (uWhites > 0.0) {
        color.rgb += uWhites * 0.005 * whiteWeight * (1.0 - color.rgb);
    } else {
        color.rgb += uWhites * 0.005 * whiteWeight * color.rgb;
    }
    
    if (uBlacks > 0.0) {
        color.rgb += uBlacks * 0.005 * blackWeight * (1.0 - color.rgb);
    } else {
        color.rgb += uBlacks * 0.005 * blackWeight * color.rgb;
    }
    
    fragColor = vec4(clamp(color.rgb, 0.0, 1.0), color.a);
}
