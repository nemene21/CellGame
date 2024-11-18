shader_type canvas_item;

void fragment() {
	COLOR.a *= texture(TEXTURE, UV).r;
}

