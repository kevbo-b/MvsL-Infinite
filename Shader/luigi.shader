shader_type canvas_item;
render_mode unshaded;

uniform vec4 newHatColor = vec4(1, 1, 1, 1);
uniform vec4 newShirtColor = vec4(0, 0.5803, 0, 1);
uniform vec4 newFlowerHatColor = vec4(0.5019608, 0.937255, 0.1490196, 1);
uniform vec4 newFlowerShirtColor = vec4(0.9686275, 0.2078431, 0.07450981, 1);

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