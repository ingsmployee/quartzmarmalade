shader_type canvas_item;

uniform float glow_radius = 3;
uniform vec4 glow_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float glow_strength = 0.1;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float color_strength;
	for(float x = -glow_radius; x < glow_radius; x += 1.0) {
		for(float y = -glow_radius; y < glow_radius; y += 1.0) {
			vec4 pixel = texture(TEXTURE, UV + vec2(x,y) * TEXTURE_PIXEL_SIZE);
			color_strength += pixel.a;
		}
	}
	
	COLOR = mix(texture(TEXTURE, UV), glow_color, glow_strength * (color_strength / pow(glow_radius, 2)));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
