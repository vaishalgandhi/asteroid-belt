shader_type canvas_item;

uniform float tint_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint_color : source_color = vec4(0.545, 0.271, 0.075, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float luminance = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 tinted = tint_color.rgb * luminance;
	vec3 result = mix(tex_color.rgb, tinted, tint_amount);
	COLOR = vec4(result, tex_color.a);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
