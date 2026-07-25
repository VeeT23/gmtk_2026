shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 10.0) = 2.0;

uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    vec2 pixel_size = 1.0 / vec2(textureSize(screen_texture, 0));

    vec4 color = vec4(0.0);

    color += texture(screen_texture, SCREEN_UV + vec2(-pixel_size.x, -pixel_size.y) * blur_strength);
    color += texture(screen_texture, SCREEN_UV + vec2(0.0, -pixel_size.y) * blur_strength);
    color += texture(screen_texture, SCREEN_UV + vec2(pixel_size.x, -pixel_size.y) * blur_strength);

    color += texture(screen_texture, SCREEN_UV + vec2(-pixel_size.x, 0.0) * blur_strength);
    color += texture(screen_texture, SCREEN_UV);
    color += texture(screen_texture, SCREEN_UV + vec2(pixel_size.x, 0.0) * blur_strength);

    color += texture(screen_texture, SCREEN_UV + vec2(-pixel_size.x, pixel_size.y) * blur_strength);
    color += texture(screen_texture, SCREEN_UV + vec2(0.0, pixel_size.y) * blur_strength);
    color += texture(screen_texture, SCREEN_UV + vec2(pixel_size.x, pixel_size.y) * blur_strength);

    COLOR = color / 9.0;
}