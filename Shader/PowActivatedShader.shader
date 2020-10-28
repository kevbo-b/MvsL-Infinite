shader_type canvas_item;
render_mode unshaded;

uniform vec4 newHatColor = vec4(1, 1, 1, 1);
uniform vec4 newShirtColor = vec4(0, 0.5803, 0, 1);
uniform vec4 newFlowerHatColor = vec4(0.5019608, 0.937255, 0.1490196, 1);
uniform vec4 newFlowerShirtColor = vec4(0.9686275, 0.2078431, 0.07450981, 1);

//uniform vec4 random_color = vec4(random(),rand(),rand(),255);

uniform float sizeMax = 1.4;
uniform float speed = 15;

void vertex(){
	float x = abs(sin(TIME * speed) * sizeMax + 1f);
	VERTEX *= vec2(x,x);	
}