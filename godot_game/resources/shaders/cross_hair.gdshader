shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;
uniform vec2 rect_size = vec2(32.0, 32.0);

uniform float radius = 0.35;

void fragment() {
    vec2 p = UV - 0.5;

    // Correct for aspect ratio
    p.x *= rect_size.x / rect_size.y;

    float d = length(p);

    if (d > radius)
        discard;

    vec3 screen = texture(screen_tex, SCREEN_UV).rgb;
    COLOR = vec4(1.0 - screen, 1.0);
}