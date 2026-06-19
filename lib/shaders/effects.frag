#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform float uTextureAdjust; // -100.0 to 100.0 (Local contrast / sharpness)
uniform float uClarity;       // -100.0 to 100.0 (Midtone contrast)
uniform float uDehaze;        // -100.0 to 100.0 (Atmospheric correction)
uniform float uVignette;      // -100.0 to 100.0 (Edge darkening/brightening)
uniform float uGrain;         // 0.0 to 100.0 (Film grain noise amount)

out vec4 fragColor;

// Pseudo-random noise generator
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = FlutterFragCoord() / uSize;
    vec4 color = texture(uTexture, uv);
    
    // 1. Texture (Micro-contrast adjustment)
    if (uTextureAdjust != 0.0) {
        vec3 blurT = vec3(0.0);
        blurT += texture(uTexture, uv + vec2(-2.0, -2.0) / uSize).rgb;
        blurT += texture(uTexture, uv + vec2(2.0, -2.0) / uSize).rgb;
        blurT += texture(uTexture, uv + vec2(-2.0, 2.0) / uSize).rgb;
        blurT += texture(uTexture, uv + vec2(2.0, 2.0) / uSize).rgb;
        blurT += color.rgb;
        blurT /= 5.0;
        
        vec3 highPassT = color.rgb - blurT;
        color.rgb += highPassT * (uTextureAdjust * 0.015);
    }
    
    // 2. Clarity (Midtone contrast adjustment)
    if (uClarity != 0.0) {
        vec3 blurC = vec3(0.0);
        blurC += texture(uTexture, uv + vec2(-5.0, 0.0) / uSize).rgb;
        blurC += texture(uTexture, uv + vec2(5.0, 0.0) / uSize).rgb;
        blurC += texture(uTexture, uv + vec2(0.0, -5.0) / uSize).rgb;
        blurC += texture(uTexture, uv + vec2(0.0, 5.0) / uSize).rgb;
        blurC += color.rgb;
        blurC /= 5.0;
        
        vec3 highPassC = color.rgb - blurC;
        float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
        // Clarity weights midtones (peaks at luma=0.5, falls to 0 at 0.0 and 1.0)
        float midtoneWeight = smoothstep(0.0, 0.5, luma) * smoothstep(1.0, 0.5, luma);
        color.rgb += highPassC * (uClarity * 0.02) * midtoneWeight;
    }
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // 3. Dehaze
    if (uDehaze != 0.0) {
        float dehazeFactor = uDehaze * 0.015;
        if (uDehaze > 0.0) {
            // Remove haze: darken blacks, boost contrast and saturation
            color.rgb = (color.rgb - vec3(0.1 * dehazeFactor)) / (1.0 - 0.1 * dehazeFactor);
            float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
            color.rgb = mix(vec3(luma), color.rgb, 1.0 + dehazeFactor * 0.3);
        } else {
            // Add haze: wash out with a grayish/blue mist
            vec3 hazeColor = vec3(0.7, 0.75, 0.8);
            color.rgb = mix(color.rgb, hazeColor, -dehazeFactor * 0.4);
        }
    }
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // 4. Vignette
    if (uVignette != 0.0) {
        float dist = length(uv - vec2(0.5));
        float vignette = pow(dist * 1.414, 2.0); // 0 at center, 1 at corner bounds
        if (uVignette < 0.0) {
            float amount = -uVignette * 0.01;
            color.rgb = mix(color.rgb, vec3(0.0), vignette * amount);
        } else {
            float amount = uVignette * 0.01;
            color.rgb = mix(color.rgb, vec3(1.0), vignette * amount);
        }
    }
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // 5. Film Grain
    if (uGrain > 0.0) {
        float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
        float noise = rand(uv * uSize);
        // Peak grain in midtones, less in highlights/shadows
        float grainWeight = 1.0 - 4.0 * (luma - 0.5) * (luma - 0.5);
        grainWeight = clamp(grainWeight, 0.1, 1.0);
        color.rgb += (noise - 0.5) * (uGrain * 0.0015) * grainWeight;
    }
    
    fragColor = vec4(clamp(color.rgb, 0.0, 1.0), color.a);
}
