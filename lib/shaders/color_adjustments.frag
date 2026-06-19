#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform float uTemperature; // -100.0 to 100.0
uniform float uTint;        // -100.0 to 100.0
uniform float uVibrance;    // -100.0 to 100.0
uniform float uSaturation;  // -100.0 to 100.0

// HSL parameters (-100.0 to 100.0)
uniform float uHslHueRed;
uniform float uHslSatRed;
uniform float uHslLumRed;

uniform float uHslHueOrange;
uniform float uHslSatOrange;
uniform float uHslLumOrange;

uniform float uHslHueYellow;
uniform float uHslSatYellow;
uniform float uHslLumYellow;

uniform float uHslHueGreen;
uniform float uHslSatGreen;
uniform float uHslLumGreen;

uniform float uHslHueAqua;
uniform float uHslSatAqua;
uniform float uHslLumAqua;

uniform float uHslHueBlue;
uniform float uHslSatBlue;
uniform float uHslLumBlue;

uniform float uHslHuePurple;
uniform float uHslSatPurple;
uniform float uHslLumPurple;

uniform float uHslHueMagenta;
uniform float uHslSatMagenta;
uniform float uHslLumMagenta;

out vec4 fragColor;

// --- RGB/HSL Conversion Utilities ---
vec3 rgb2hsl(vec3 c) {
    float maxVal = max(c.r, max(c.g, c.b));
    float minVal = min(c.r, min(c.g, c.b));
    float delta = maxVal - minVal;

    float h = 0.0;
    float s = 0.0;
    float l = (maxVal + minVal) * 0.5;

    if (delta > 0.0) {
        s = l < 0.5 ? (delta / (maxVal + minVal)) : (delta / (2.0 - maxVal - minVal));

        if (maxVal == c.r) {
            h = (c.g - c.b) / delta + (c.g < c.b ? 6.0 : 0.0);
        } else if (maxVal == c.g) {
            h = (c.b - c.r) / delta + 2.0;
        } else if (maxVal == c.b) {
            h = (c.r - c.g) / delta + 4.0;
        }
        h /= 6.0;
    }
    return vec3(h, s, l);
}

float hue2rgb(float p, float q, float t) {
    if (t < 0.0) t += 1.0;
    if (t > 1.0) t -= 1.0;
    if (t < 1.0/6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0/2.0) return q;
    if (t < 2.0/3.0) return p + (q - p) * (2.0/3.0 - t) * 6.0;
    return p;
}

vec3 hsl2rgb(vec3 hsl) {
    float h = hsl.x;
    float s = hsl.y;
    float l = hsl.z;
    vec3 rgb;

    if (s == 0.0) {
        rgb = vec3(l); // achromatic
    } else {
        float q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
        float p = 2.0 * l - q;
        rgb.r = hue2rgb(p, q, h + 1.0/3.0);
        rgb.g = hue2rgb(p, q, h);
        rgb.b = hue2rgb(p, q, h - 1.0/3.0);
    }
    return rgb;
}

float getHueWeight(float h, float center, float width) {
    float dist = abs(h - center);
    if (dist > 0.5) {
        dist = 1.0 - dist;
    }
    return smoothstep(width, 0.0, dist);
}

void main() {
    vec2 uv = FlutterFragCoord() / uSize;
    vec4 color = texture(uTexture, uv);
    
    // 1. Temperature & Tint Adjustment
    // Temperature: shift towards blue/yellow
    color.r += uTemperature * 0.0015;
    color.b -= uTemperature * 0.0015;
    // Tint: shift towards green/magenta
    color.g -= uTint * 0.0015;
    color.r += uTint * 0.00075;
    color.b += uTint * 0.00075;
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // 2. Vibrance Adjustment (Smart Saturation)
    float maxColor = max(color.r, max(color.g, color.b));
    float minColor = min(color.r, min(color.g, color.b));
    float satAmt = (maxColor - minColor) * 3.0; // Saturation measure
    float vibranceFactor = uVibrance * 0.01 * (1.0 - clamp(satAmt, 0.0, 1.0));
    float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(vec3(luma), color.rgb, 1.0 + vibranceFactor);
    
    // 3. Saturation Adjustment (Global)
    color.rgb = mix(vec3(luma), color.rgb, 1.0 + uSaturation * 0.01);
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // 4. HSL Channel Targeting (Red, Orange, Yellow, Green, Aqua, Blue, Purple, Magenta)
    vec3 hsl = rgb2hsl(color.rgb);
    
    float rWeight = getHueWeight(hsl.x, 0.0, 0.1) + getHueWeight(hsl.x, 1.0, 0.1);
    float oWeight = getHueWeight(hsl.x, 0.0833, 0.0833);
    float yWeight = getHueWeight(hsl.x, 0.1667, 0.0833);
    float gWeight = getHueWeight(hsl.x, 0.3333, 0.1667);
    float aWeight = getHueWeight(hsl.x, 0.5, 0.1667);
    float bWeight = getHueWeight(hsl.x, 0.6667, 0.1667);
    float pWeight = getHueWeight(hsl.x, 0.7639, 0.0972);
    float mWeight = getHueWeight(hsl.x, 0.875, 0.1111);
    
    float totalWeight = rWeight + oWeight + yWeight + gWeight + aWeight + bWeight + pWeight + mWeight;
    if (totalWeight > 0.0) {
        rWeight /= totalWeight;
        oWeight /= totalWeight;
        yWeight /= totalWeight;
        gWeight /= totalWeight;
        aWeight /= totalWeight;
        bWeight /= totalWeight;
        pWeight /= totalWeight;
        mWeight /= totalWeight;
    }
    
    float hueShift = (
        rWeight * uHslHueRed +
        oWeight * uHslHueOrange +
        yWeight * uHslHueYellow +
        gWeight * uHslHueGreen +
        aWeight * uHslHueAqua +
        bWeight * uHslHueBlue +
        pWeight * uHslHuePurple +
        mWeight * uHslHueMagenta
    ) / 100.0;
    
    float satShift = (
        rWeight * uHslSatRed +
        oWeight * uHslSatOrange +
        yWeight * uHslSatYellow +
        gWeight * uHslSatGreen +
        aWeight * uHslSatAqua +
        bWeight * uHslSatBlue +
        pWeight * uHslSatPurple +
        mWeight * uHslSatMagenta
    ) / 100.0;
    
    float lumShift = (
        rWeight * uHslLumRed +
        oWeight * uHslLumOrange +
        yWeight * uHslLumYellow +
        gWeight * uHslLumGreen +
        aWeight * uHslLumAqua +
        bWeight * uHslLumBlue +
        pWeight * uHslLumPurple +
        mWeight * uHslLumMagenta
    ) / 100.0;
    
    // Apply shifts:
    // Hue Shift max +/- 30 degrees (0.0833 of full circle)
    hsl.x = fract(hsl.x + hueShift * 0.0833);
    
    if (satShift > 0.0) {
        hsl.y = mix(hsl.y, 1.0, satShift);
    } else {
        hsl.y = mix(hsl.y, 0.0, -satShift);
    }
    
    if (lumShift > 0.0) {
        hsl.z = mix(hsl.z, 1.0, lumShift * 0.8);
    } else {
        hsl.z = mix(hsl.z, 0.0, -lumShift * 0.8);
    }
    
    color.rgb = hsl2rgb(hsl);
    fragColor = vec4(clamp(color.rgb, 0.0, 1.0), color.a);
}
