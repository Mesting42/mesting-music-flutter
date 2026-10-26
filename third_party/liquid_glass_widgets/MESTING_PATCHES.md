# Mesting Beta.12 optical correction

The `package/` folder vendors liquid_glass_widgets 1.15.0, under its MIT license.
The application's dependency override uses this directory so the APK and source
archive contain exactly the same renderer. The installed Pub cache is unchanged.

Changed upstream file: `shaders/lightweight_glass.frag`.

The fallback shader previously added a 0.65 base perimeter, plus a dark-only
minimum rim floor, independently of directional light and Fresnel settings.
Dark surfaces therefore looked uniformly outlined even with fresnelStrength=0.
The patch suppresses those two constant perimeter terms for dark backdrop luma.
Directional specular lobes, refractive displacement, chromatic dispersion,
meniscus absorption, touch feedback, body tint and light-mode calibration remain.

The premium renderer is not replaced. At the application level, adaptive quality
is disabled to honor the requirement that scrolling must retain premium optics.
The shared blue action uses the upstream clear body mode (alpha tint with
specular/refraction) to prevent light-background luminance normalization from
turning its normal blue into pale cyan.

Verification distinguishes software-renderer captures from actual device GPU
evidence. A successful host capture does not certify Android native refraction.
