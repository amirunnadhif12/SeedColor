#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform sampler2D uLutTexture; // 256x1 texture: R=Red, G=Green, B=Blue, A=RGB curve

// --- Step 1: Light Adjustments ---
uniform float uExposure;   // -5.0 to 5.0
uniform float uContrast;   // -100.0 to 100.0
uniform float uHighlights; // -100.0 to 100.0
uniform float uShadows;    // -100.0 to 100.0
uniform float uWhites;     // -100.0 to 100.0
uniform float uBlacks;     // -100.0 to 100.0

// --- Step 2: Color Adjustments & HSL ---
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

// --- Step 3: Effects ---
uniform float uTextureAdjust; // -100.0 to 100.0
uniform float uClarity;       // -100.0 to 100.0
uniform float uDehaze;        // -100.0 to 100.0
uniform float uVignette;      // -100.0 to 100.0
uniform float uGrain;         // 0.0 to 100.0

// --- Step 4: Color Grading ---
uniform vec3 uShadowsColor;     // Shadows RGB tint color
uniform vec3 uMidtonesColor;    // Midtones RGB tint color
uniform vec3 uHighlightsColor;  // Highlights RGB tint color
uniform float uBlending;        // Blending factor (0.0 to 1.0)
uniform float uBalance;         // Balance factor (-1.0 to 1.0)

// --- Step 5: Detail & Optics ---
uniform float uSharpeningAmount;
uniform float uSharpeningRadius;
uniform float uSharpeningDetail;
uniform float uSharpeningMasking;
uniform float uLuminanceNR;
uniform float uColorNR;
uniform float uRemoveChromaticAberration;
uniform float uEnableLensCorrection;

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

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 rgb2ycbcr(vec3 c) {
    float y = 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
    float cb = (c.b - y) * 0.564 + 0.5;
    float cr = (c.r - y) * 0.713 + 0.5;
    return vec3(y, cb, cr);
}

vec3 ycbcr2rgb(vec3 ycc) {
    float y = ycc.x;
    float cb = ycc.y - 0.5;
    float cr = ycc.z - 0.5;
    float r = y + 1.402 * cr;
    float g = y - 0.344 * cb - 0.714 * cr;
    float b = y + 1.772 * cb;
    return vec3(max(0.0, r), max(0.0, g), max(0.0, b));
}

void main() {
    vec2 uv = FlutterFragCoord() / uSize;
    
    // Lens Correction
    if (uEnableLensCorrection > 0.0) {
        vec2 toCenter = uv - vec2(0.5);
        float r2 = dot(toCenter, toCenter);
        float k1 = -0.06;
        uv = vec2(0.5) + toCenter * (1.0 + k1 * r2);
        
        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
            fragColor = vec4(0.0, 0.0, 0.0, 1.0);
            return;
        }
    }
    
    // Chromatic Aberration
    vec4 color;
    if (uRemoveChromaticAberration > 0.0) {
        vec2 toCenter = uv - vec2(0.5);
        float dist = length(toCenter);
        vec2 uvRed = vec2(0.5) + toCenter * (1.0 - 0.0015 * dist);
        vec2 uvBlue = vec2(0.5) + toCenter * (1.0 + 0.0015 * dist);
        
        color.r = texture(uTexture, uvRed).r;
        color.g = texture(uTexture, uv).g;
        color.b = texture(uTexture, uvBlue).b;
        color.a = texture(uTexture, uv).a;
    } else {
        color = texture(uTexture, uv);
    }
    
    // ==========================================
    // 1. Light Adjustments (adjustments.frag)
    // ==========================================
    
    // 1a. Exposure
    color.rgb *= pow(2.0, uExposure);
    
    // 1b. Contrast
    float contrastFactor = (uContrast + 100.0) / 100.0;
    color.rgb = (color.rgb - vec3(0.5)) * contrastFactor + vec3(0.5);
    
    // 1c. Highlights & Shadows
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
    
    // 1d. Whites & Blacks (recalculate luma)
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
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // ==========================================
    // 2. Color Adjustments & HSL (color_adjustments.frag)
    // ==========================================
    
    // 2a. Temperature & Tint Adjustment
    color.r += uTemperature * 0.0015;
    color.b -= uTemperature * 0.0015;
    color.g -= uTint * 0.0015;
    color.r += uTint * 0.00075;
    color.b += uTint * 0.00075;
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // 2b. Vibrance (Smart Saturation)
    float maxColor = max(color.r, max(color.g, color.b));
    float minColor = min(color.r, min(color.g, color.b));
    float satAmt = (maxColor - minColor) * 3.0;
    float vibranceFactor = uVibrance * 0.01 * (1.0 - clamp(satAmt, 0.0, 1.0));
    luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(vec3(luma), color.rgb, 1.0 + vibranceFactor);
    
    // 2c. Saturation (Global)
    color.rgb = mix(vec3(luma), color.rgb, 1.0 + uSaturation * 0.01);
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // 2d. HSL Mixer
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
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // ==========================================
    // 3. Curves (curves.frag)
    // ==========================================
    
    // Apply R, G, B curves from LUT
    float cr = texture(uLutTexture, vec2(color.r, 0.5)).r;
    float cg = texture(uLutTexture, vec2(color.g, 0.5)).g;
    float cb = texture(uLutTexture, vec2(color.b, 0.5)).b;

    // Apply combined RGB curve (stored in A channel)
    color.r = texture(uLutTexture, vec2(cr, 0.5)).a;
    color.g = texture(uLutTexture, vec2(cg, 0.5)).a;
    color.b = texture(uLutTexture, vec2(cb, 0.5)).a;
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // ==========================================
    // 4. Effects (effects.frag)
    // ==========================================
    
    // 4a. Texture (Micro-contrast)
    if (uTextureAdjust != 0.0) {
        vec3 blurT = vec3(0.0);
        blurT += texture(uTexture, uv + vec2(-2.0, -2.0) / uSize).rgb;
        blurT += texture(uTexture, uv + vec2(2.0, -2.0) / uSize).rgb;
        blurT += texture(uTexture, uv + vec2(-2.0, 2.0) / uSize).rgb;
        blurT += texture(uTexture, uv + vec2(2.0, 2.0) / uSize).rgb;
        blurT += texture(uTexture, uv).rgb;
        blurT /= 5.0;
        
        vec3 highPassT = texture(uTexture, uv).rgb - blurT;
        color.rgb += highPassT * (uTextureAdjust * 0.015);
    }
    
    // 4b. Clarity (Midtone contrast)
    if (uClarity != 0.0) {
        vec3 blurC = vec3(0.0);
        blurC += texture(uTexture, uv + vec2(-5.0, 0.0) / uSize).rgb;
        blurC += texture(uTexture, uv + vec2(5.0, 0.0) / uSize).rgb;
        blurC += texture(uTexture, uv + vec2(0.0, -5.0) / uSize).rgb;
        blurC += texture(uTexture, uv + vec2(0.0, 5.0) / uSize).rgb;
        blurC += texture(uTexture, uv).rgb;
        blurC /= 5.0;
        
        vec3 highPassC = texture(uTexture, uv).rgb - blurC;
        luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
        float midtoneWeight = smoothstep(0.0, 0.5, luma) * smoothstep(1.0, 0.5, luma);
        color.rgb += highPassC * (uClarity * 0.02) * midtoneWeight;
    }
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // 4c. Dehaze
    if (uDehaze != 0.0) {
        float dehazeFactor = uDehaze * 0.015;
        if (uDehaze > 0.0) {
            color.rgb = (color.rgb - vec3(0.1 * dehazeFactor)) / (1.0 - 0.1 * dehazeFactor);
            luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
            color.rgb = mix(vec3(luma), color.rgb, 1.0 + dehazeFactor * 0.3);
        } else {
            vec3 hazeColor = vec3(0.7, 0.75, 0.8);
            color.rgb = mix(color.rgb, hazeColor, -dehazeFactor * 0.4);
        }
    }
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // 4d. Vignette
    if (uVignette != 0.0) {
        float dist = length(uv - vec2(0.5));
        float vignette = pow(dist * 1.414, 2.0);
        if (uVignette < 0.0) {
            float amount = -uVignette * 0.01;
            color.rgb = mix(color.rgb, vec3(0.0), vignette * amount);
        } else {
            float amount = uVignette * 0.01;
            color.rgb = mix(color.rgb, vec3(1.0), vignette * amount);
        }
    }
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // 4e. Film Grain
    if (uGrain > 0.0) {
        luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
        float noise = rand(uv * uSize);
        float grainWeight = 1.0 - 4.0 * (luma - 0.5) * (luma - 0.5);
        grainWeight = clamp(grainWeight, 0.1, 1.0);
        color.rgb += (noise - 0.5) * (uGrain * 0.0015) * grainWeight;
    }
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // ==========================================
    // 4.5. Sharpening & Noise Reduction
    // ==========================================
    
    // Sharpening (Amount, Radius, Detail, Masking)
    if (uSharpeningAmount > 0.0) {
        vec2 offset = vec2(uSharpeningRadius) / uSize;
        vec3 center = texture(uTexture, uv).rgb;
        vec3 left   = texture(uTexture, uv + vec2(-offset.x, 0.0)).rgb;
        vec3 right  = texture(uTexture, uv + vec2(offset.x, 0.0)).rgb;
        vec3 top    = texture(uTexture, uv + vec2(0.0, -offset.y)).rgb;
        vec3 bottom = texture(uTexture, uv + vec2(0.0, offset.y)).rgb;
        
        // Edge detection for masking
        float lCenter = dot(center, vec3(0.299, 0.587, 0.114));
        float lLeft   = dot(left, vec3(0.299, 0.587, 0.114));
        float lRight  = dot(right, vec3(0.299, 0.587, 0.114));
        float lTop    = dot(top, vec3(0.299, 0.587, 0.114));
        float lBottom = dot(bottom, vec3(0.299, 0.587, 0.114));
        
        float edge = (abs(lCenter - lLeft) + abs(lCenter - lRight) + abs(lCenter - lTop) + abs(lCenter - lBottom)) * 0.25;
        float edgeMask = 1.0;
        if (uSharpeningMasking > 0.0) {
            edgeMask = smoothstep(uSharpeningMasking * 0.001, uSharpeningMasking * 0.001 + 0.005, edge);
        }
        
        vec3 laplacian = center * 4.0 - left - right - top - bottom;
        vec3 sharpenDelta = laplacian * (uSharpeningAmount * 0.015 * (1.0 + uSharpeningDetail * 0.01));
        
        color.rgb += sharpenDelta * edgeMask;
    }
    
    // Noise Reduction (Luminance, Color)
    if (uLuminanceNR > 0.0 || uColorNR > 0.0) {
        vec3 nrColor = vec3(0.0);
        float totalWeight = 0.0;
        vec3 centerVal = texture(uTexture, uv).rgb;
        float lumaCenter = dot(centerVal, vec3(0.299, 0.587, 0.114));
        
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                vec2 sampleUv = uv + vec2(float(x), float(y)) * 1.5 / uSize;
                vec3 sampleColor = texture(uTexture, sampleUv).rgb;
                float sampleLuma = dot(sampleColor, vec3(0.299, 0.587, 0.114));
                
                float dLuma = sampleLuma - lumaCenter;
                float wRange = exp(-dLuma * dLuma * 20.0);
                float weight = wRange;
                
                nrColor += sampleColor * weight;
                totalWeight += weight;
            }
        }
        if (totalWeight > 0.0) {
            nrColor /= totalWeight;
        } else {
            nrColor = centerVal;
        }
        
        vec3 yccOrig = rgb2ycbcr(color.rgb);
        vec3 yccBlurred = rgb2ycbcr(nrColor);
        
        if (uLuminanceNR > 0.0) {
            float scaleY = yccOrig.x / max(yccBlurred.x, 0.001);
            float targetY = yccBlurred.x * scaleY;
            yccOrig.x = mix(yccOrig.x, targetY, uLuminanceNR * 0.008);
        }
        if (uColorNR > 0.0) {
            yccOrig.yz = mix(yccOrig.yz, yccBlurred.yz, uColorNR * 0.008);
        }
        color.rgb = ycbcr2rgb(yccOrig);
    }
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // ==========================================
    // 5. Color Grading (color_grading.frag)
    // ==========================================
    luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    
    float balancedLuma = luma;
    if (uBalance > 0.0) {
        balancedLuma = pow(luma, 1.0 / (1.0 + uBalance * 0.5));
    } else if (uBalance < 0.0) {
        balancedLuma = pow(luma, 1.0 - uBalance * 0.5);
    }
    
    float blend = uBlending;
    float sEnd = mix(0.25, 0.5, blend);
    float hStart = mix(0.75, 0.5, blend);
    
    float wShadow = smoothstep(sEnd, 0.0, balancedLuma);
    float wHighlight = smoothstep(hStart, 1.0, balancedLuma);
    float wMidtone = max(0.0, 1.0 - wShadow - wHighlight);
    
    color.rgb += uShadowsColor * wShadow * (1.0 - color.rgb) * 0.5;
    color.rgb += uMidtonesColor * wMidtone * (1.0 - color.rgb) * 0.5;
    color.rgb += uHighlightsColor * wHighlight * (1.0 - color.rgb) * 0.5;
    
    fragColor = vec4(clamp(color.rgb, 0.0, 1.0), color.a);
}
