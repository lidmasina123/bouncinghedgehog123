shader_type canvas_item;

uniform bool remove_neutral_background = false;
uniform vec4 excluded_region = vec4(0.0);

void fragment() {
	vec4 art = texture(TEXTURE, UV);
	float lightest = max(art.r, max(art.g, art.b));
	float darkest = min(art.r, min(art.g, art.b));
	float coverage = 1.0 - smoothstep(0.90, 0.99, darkest);

	if (remove_neutral_background) {
		coverage *= smoothstep(0.03, 0.16, lightest - darkest);
	}

	if (all(greaterThanEqual(UV, excluded_region.xy)) &&
			all(lessThan(UV, excluded_region.zw))) {
		coverage = 0.0;
	}
	COLOR = vec4(art.rgb, art.a * coverage);
}

