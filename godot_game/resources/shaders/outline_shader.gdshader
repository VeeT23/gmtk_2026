shader_type spatial;
render_mode cull_front, unshaded;

// Most of the code is by axilirate with some tweaks by Veeronii

// To use, go to your MeshInstance3D
// Then under Geometry > Material Overlay, make a new shader material
// Then apply this shader to the Shader resource

// Another thing, if your outline has a bunch of sharp edges its because the vertex normals aren't normalized.
// In blender, select your mesh and add the "Weighted Normal" modifier
// If you want to preserve the original look, check "keep sharp"
// Then apply and reimport into godot.

instance uniform bool enabled = false;
uniform vec4 outline_color : source_color;
uniform float outline_width = 1.0;

void vertex() {
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);
	
	vec2 offset = normalize(clip_normal.xy) / VIEWPORT_SIZE * clip_position.w * outline_width * 2.0;
	
	clip_position.xy += offset;
	
	POSITION = clip_position;
}

void fragment() {
	
	if (!enabled) {
		discard;
	}
	
	ALBEDO = outline_color.rgb;
	if (outline_color.a < 1.0) {
		ALPHA = outline_color.a;
	}
}