shader_type canvas_item;

uniform vec4 tint: source_color;
uniform float scan_speed: hint_range(0.0, 1.0, 0.1);
uniform float scan_frequency: hint_range(0.0, 100.0, 0.1);
uniform float scan_strength: hint_range(0.0, 1.0, 0.1);

uniform sampler2D noise: repeat_enable;
uniform float warp_speed: hint_range(0.0, 1.0, 0.1);
uniform float warp_frequency: hint_range(0.0, 100.0, 0.1);
uniform float warp_strength: hint_range(0.0, .3, 0.01);

void fragment() {
	float warp = texture(noise, vec2(TIME * warp_speed * warp_speed + UV.y * warp_frequency, 0)).r;
	warp = (warp * 2.0 - 1.0) * warp_strength;

	vec4 pixel = texture(TEXTURE, UV + vec2(warp, 0));
	float grayscale = (pixel.r + pixel.g + pixel.b) * 0.33;

	float scanline = 1.0 + sin(TIME * scan_speed * scan_frequency + UV.y * scan_frequency) * scan_strength;

	COLOR = vec4(grayscale, grayscale, grayscale, pixel.a) * tint;
	COLOR.rgb *= scanline;
}
