shader_type canvas_item;
render_mode unshaded;

uniform vec4 newBlack = vec4(0, 0.1764706, 0.3764706, 1);

void fragment() {
    vec4 col = texture(TEXTURE, UV);

	if(col.a > 0f){
		if(col.r <= 0.1f)
		{
        	col = newBlack;
		}
	}
    COLOR = col;
}