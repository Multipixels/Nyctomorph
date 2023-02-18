shader_type canvas_item;

uniform vec4 oldColor1 : hint_color;
uniform vec4 oldColor2 : hint_color;

uniform vec4 newColor1 : hint_color;
uniform vec4 newColor2 : hint_color;

void fragment() {
	vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	vec4 t = vec4(c, 1.0);
	
	if (distance(t, oldColor1) < 0.01) {
		COLOR = newColor1;
	} else if (distance(t, oldColor2) < 0.01) {
		COLOR = newColor2;
	} else {
		COLOR = vec4(0, 0, 0, 0);
	}
}
