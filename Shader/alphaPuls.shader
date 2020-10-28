shader_type canvas_item;
render_mode unshaded;

uniform float change_speed = 7f;

void fragment() {
	
    vec4 col = texture(TEXTURE, UV);

	if(col.a > 0f){
		col.a = abs(sin(change_speed * TIME) * 0.8f);
	}
    
	COLOR = col;
}