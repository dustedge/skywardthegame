shader_type canvas_item;

uniform vec2 fragment_size = vec2(0.1, 0.1);  // Size of the fragments
uniform float breakup = 0.0;  // Progress of the breakup effect (0.0 to 1.0)

// Custom random function
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453);
}


void fragment() {
    vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;
    vec2 cell = floor(uv / fragment_size);
    float breakup_amount = breakup + random(cell.xy);
    if (breakup_amount > 1.0) {
        discard;  // Remove fragment
    }
    COLOR = texture(TEXTURE, UV);
}
//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
