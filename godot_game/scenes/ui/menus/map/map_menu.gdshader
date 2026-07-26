shader_type canvas_item;

uniform vec2 circle_position = vec2(0.5, 0.5);
uniform float radius = 0.1;
uniform vec4 circle_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

// Outside brightness
uniform float outside_brightness : hint_range(0.0, 3.0) = 0.5;

// Pulse
uniform float pulse_speed = 1.0;
uniform float pulse_start_offset = 0.0;
uniform float pulse_end_offset = 0.35;

uniform float pulse_thickness = 0.02;
uniform float pulse_inner_width = 0.003;
uniform float pulse_outer_width = 0.003;

uniform float pulse_fade_power = 1.0;

uniform vec4 pulse_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float dist = distance(UV, circle_position);

    vec4 base_color;

    if (dist < radius) {
        base_color = circle_color;
    } else {
        base_color = vec4(tex_color.rgb * outside_brightness, tex_color.a);
    }

    // Pulse animation (0-1)
    float t = fract(TIME * pulse_speed);

    // Current radius of pulse
    float ring_radius = radius +
        mix(pulse_start_offset, pulse_end_offset, t);

    // Ring with adjustable thickness and feathering
    float inner = smoothstep(
        ring_radius - pulse_thickness * 0.5 - pulse_inner_width,
        ring_radius - pulse_thickness * 0.5,
        dist
    );

    float outer = 1.0 - smoothstep(
        ring_radius + pulse_thickness * 0.5,
        ring_radius + pulse_thickness * 0.5 + pulse_outer_width,
        dist
    );

    float ring = inner * outer;

    // Fade as it expands
    float fade = pow(1.0 - t, pulse_fade_power);

    // Additive glow
    base_color.rgb += pulse_color.rgb * ring * fade * pulse_color.a;

    COLOR = base_color;
}