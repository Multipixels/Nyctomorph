shader_type canvas_item;

uniform vec4 oldColor1 : hint_color;
uniform vec4 oldColor2 : hint_color;

uniform vec4 oldColor3 : hint_color;
uniform vec4 oldColor4 : hint_color;

uniform vec4 newColor1 : hint_color;
uniform vec4 newColor2 : hint_color;

void fragment() {
	vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	vec4 t = vec4(c, 1.0);
	
	if (distance(t, newColor1) < 0.01) {
		COLOR = newColor1
	} else if (distance(t, newColor2) < 0.01) {
		COLOR = newColor2
	} else if (distance(t, oldColor1) < 0.01 || distance(t, oldColor3) < 0.01) {
		COLOR = newColor1;
	} else if (distance(t, oldColor2) < 0.01 || distance(t, oldColor4) < 0.01) {
		COLOR = newColor2;
	} else if (distance(t, vec4(0, 0, 0, 0)) < 1.18) {
		COLOR = t
	} else {
		COLOR = newColor2;
	}
}
