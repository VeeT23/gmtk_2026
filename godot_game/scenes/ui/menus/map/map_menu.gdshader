shader_type canvas_item;

uniform vec2 circle_position = vec2(0.5, 0.5);
uniform float radius = 0.1;
uniform vec4 circle_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

// Outside brightness: 1.0 = normal, <1.0 = darker, >1.0 = lighter
uniform float outside_brightness : hint_range(0.0, 3.0) = 0.5;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    float dist = distance(UV, circle_position);

    if (dist < radius) {
        // Keep the circle untouched
        COLOR = circle_color;
    } else {
        // Modulate everything else
        COLOR = vec4(tex_color.rgb * outside_brightness, tex_color.a);
    }
}