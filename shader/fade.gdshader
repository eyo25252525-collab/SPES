shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform sampler2D noise_texture : repeat_enable, filter_nearest;
uniform vec4 transition_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float max_pixel_size : hint_range(2.0, 128.0) = 48.0;
uniform float smoothness : hint_range(0.01, 0.5) = 0.1;

void fragment() {
	// Phase 1 (0 -> 0.5) : la pixelisation augmente
	float pix_t = clamp(progress * 2.0, 0.0, 1.0);
	// Phase 2 (0.5 -> 1) : dissolution en blocs
	float dis_t = clamp(progress * 2.0 - 1.0, 0.0, 1.0);

	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	float pixel_size = mix(1.0, max_pixel_size, pix_t);
	vec2 grid = screen_size / pixel_size;

	// On "snap" l'UV au centre de chaque bloc
	vec2 uv = (floor(SCREEN_UV * grid) + 0.5) / grid;

	vec4 scene = texture(screen_texture, uv);

	// Le bruit est lu au même UV, donc la dissolution se fait bloc par bloc
	float n = texture(noise_texture, uv).r;
	float p = dis_t * (1.0 + smoothness);
	float cover = 1.0 - smoothstep(p - smoothness, p, n);

	COLOR = vec4(mix(scene.rgb, transition_color.rgb, cover), 1.0);
}