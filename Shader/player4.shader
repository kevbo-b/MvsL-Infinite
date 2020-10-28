shader_type canvas_item;
render_mode unshaded;

uniform vec4 newHatColor = vec4(1, 0.8627452, 0.4509804, 1);
uniform vec4 newShirtColor = vec4(0.6509804, 0.4862745, 0, 1);
uniform vec4 newFlowerHatColor = vec4(1,1,1,1);
uniform vec4 newFlowerShirtColor = vec4(1, 0.3803922, 0, 1);

//uniform vec4 random_color = vec4(random(),rand(),rand(),255);

void fragment() {
    vec4 col = texture(TEXTURE, UV);

	if(col.a > 0f){
		if(col.r >= 1f)
		{
        	col = newHatColor;
		}else if(col.g > 0f && col.g < 0.3){
			col = newFlowerShirtColor;
    	}else if(col.b == 0f){
			col = newShirtColor;	
		}else if(col.g < 1f && col.g > 0.75){
			col = newFlowerHatColor;
		}
		
	}
    COLOR = col;
}