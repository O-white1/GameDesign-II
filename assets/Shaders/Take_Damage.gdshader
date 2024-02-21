shader_type canvas_item;

uniform float intensity;


void fragment() {
	vec4 BaseColor = vec4(1.0, 0.0, 0.0, 0.0);
	BaseColor.a = intensity * 0.8;
	COLOR = BaseColor;
}
