shader_type canvas_item;

uniform vec2 scroll;
uniform float speed;

void fragment() {
	COLOR = texture(TEXTURE, UV + TIME * scroll * speed);
}

