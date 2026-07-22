shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float pixel_size = 8.0;

void fragment() {
    vec2 screen_size = vec2(textureSize(screen_texture, 0));

    vec2 pixel = floor(SCREEN_UV * screen_size / pixel_size);
    vec2 uv = (pixel * pixel_size + pixel_size * 0.5) / screen_size;

    COLOR = texture(screen_texture, uv);
}
