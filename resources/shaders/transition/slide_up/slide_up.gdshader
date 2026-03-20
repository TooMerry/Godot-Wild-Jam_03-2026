shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0, 0.01) = 0.0;
instance uniform bool inverted = false;

void fragment() {
	vec2 uv = UV;
	
	if (inverted) {
		COLOR.a = step(uv.y, progress);
	} else {
		COLOR.a = step(1.0 - uv.y, progress);
	}
}
