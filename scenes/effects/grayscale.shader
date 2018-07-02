shader_type canvas_item;

uniform float gray_intensity : hint_range(0, 1);
uniform float white_mix : hint_range(0, 1);

void fragment() {
	vec3 c = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	
	// Dot product honors light intensity.
	float v = dot(c, vec3(0.299, 0.587, 0.114));
	COLOR.rgb = vec3(v) * gray_intensity + c * (1.0 - gray_intensity);
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0), white_mix);
}