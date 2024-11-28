shader_type canvas_item;

void fragment() {
	COLOR = textureLod(TEXTURE, UV, 5.0);
	COLOR.rgb *= 0.0;
}
