shader_type canvas_item;
render_mode unshaded;

uniform vec4 newHatColor = vec4(1, 0.8627452, 0.4509804, 1);
uniform vec4 newShirtColor = vec4(0.6509804, 0.4862745, 0, 1);
uniform vec4 newFlowerHatColor = vec4(1,1,1,1);
uniform vec4 newFlowerShirtColor = vec4(1, 0.3803922, 0, 1);

//uniform vec4 random_color = vec4(random(),rand(),rand(),255);

uniform float PI = 3.14159265358979f;
uniform float change_speed = 7f;

void fragment() {
	
    vec4 col = texture(TEXTURE, UV);

	if(col.a > 0f){
			if(col.r >= 1f || (col.g < 1f && col.g > 0.75)){ //hat normal
        		col = vec4(sin(change_speed * TIME),cos(change_speed * TIME),sin(change_speed * TIME - (PI / 2f)),1);
			}else if(col.b == 0f){ //shirt, beard
				col = vec4(sin(change_speed * TIME),sin(change_speed * TIME - (PI / 2f)),cos(change_speed * TIME),1);
			}else{ //skin
        		col = vec4(cos(change_speed * TIME),cos(change_speed * TIME -(PI / 2f)),sin(change_speed * TIME),1);
			}
		col = vec4(col.r + COLOR.r, col.g/2f + COLOR.g, col.b + COLOR.b, 1);
	}
    
	COLOR = col;
}