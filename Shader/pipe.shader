shader_type canvas_item;
render_mode unshaded;

uniform vec4 newCol1 = vec4(0.878, 0.620, 0.165, 1);
uniform vec4 newCol2 = vec4(0.682, 0.184, 0.157, 1);
uniform vec4 newCol3 = vec4(0, 0, 0.149, 1);

void fragment() {
    vec4 col = texture(TEXTURE, UV);

	if(col.a > 0f){
		if(col.r > 0.5f){
			col = newCol1;
    	}else if(col.g > 0f){
			col = newCol2;
		}else if(col.g == 0f){
			col = newCol3;
		}
		
	}
    COLOR = col;
}