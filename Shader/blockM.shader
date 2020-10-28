shader_type canvas_item;
render_mode unshaded;

uniform vec4 color1 = vec4(1, 1, 1, 1);
uniform vec4 color3 = vec4(0.5, 0.5, 0.5, 1);
uniform vec4 color2 = vec4(0.2, 0.2, 0.2, 1);

//uniform vec4 random_color = vec4(random(),rand(),rand(),255);

void fragment() {
    vec4 col = texture(TEXTURE, UV);

	if(col.a > 0f){
		if(col.b >= 0.6)
		{
        	col = color1;
		}else if(col.b > 0f){
			col = color2;
    	}else if(col.g == 0f){
			col = color3;
		}
	}
    COLOR = col;
}