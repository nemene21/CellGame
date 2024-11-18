shader_type canvas_item;

uniform float flash;

void fragment() {
	COLOR.rgb = COLOR.rgb * (1.0 - flash) + flash;
}
