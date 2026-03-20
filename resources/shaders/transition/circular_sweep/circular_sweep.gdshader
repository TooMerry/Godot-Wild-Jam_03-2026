shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0, 0.01) = 0.0;
instance uniform bool inverted = false;

void fragment() {
	vec2 uv = UV;
	
	// Direction from center
	vec2 dir = uv - vec2(0.5);
	
	// Angle from -PI to PI
	float angle = atan(dir.y, dir.x);
	
	// Angle from 0 to 1
	float normalized_angle = (angle + PI) / (2.0 * PI);
	
	if (inverted) {
		COLOR.a = step(1.0 - normalized_angle, progress);
	} else {
		COLOR.a = step(normalized_angle, progress);
	}
}
