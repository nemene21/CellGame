shader_type canvas_item;

uniform sampler2D screen: hint_screen_texture;
uniform float vignetteExpo;
uniform float vignetteMult;
const vec2 aspectRatio = vec2(1, 180.0 / 320.0);
const vec2 CENTER = vec2(.5, .5);

uniform sampler2D displacementNoise: repeat_enable;
uniform float displacementFps: hint_range(0.0, 10, 1);
uniform float displacementStrength: hint_range(0.0, 0.05, 0.001);

void fragment() {
	// Displacement noise
	float noiseOffset = floor(TIME * displacementFps) * 1.123456789;
	float displacement = texture(displacementNoise, SCREEN_UV + noiseOffset).r * displacementStrength;

	// Vignette
	float dist = length(CENTER - SCREEN_UV);

	dist = pow(dist, vignetteExpo);
	dist *= vignetteMult;

	COLOR = texture(screen, SCREEN_UV + displacement);
}
