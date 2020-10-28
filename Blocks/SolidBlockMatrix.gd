extends StaticBody2D

export(int, "0 (Green Overworld)","1 (Underground)","2 (Castle)","3 (Snow)","4 (Custom Ice)","5 (Water/World 9)","6 (Red Overworld)") var palette = 0;

const BLOCK_SIZE = 16;

const BLOCK_SHADER = preload("res://Shader/blockM.shader");

export var sizeOf = Vector2(1,1);


var repeatingTexture;

func _ready():
	$MatrixSprite.region_rect.size.x = BLOCK_SIZE * sizeOf.x;
	$MatrixSprite.region_rect.size.y = BLOCK_SIZE * sizeOf.y;
	
	$Collision.scale = Vector2(sizeOf.x * 0.8, sizeOf.y * 0.8);
	$Collision.position = Vector2(sizeOf.x * BLOCK_SIZE / 2, sizeOf.y * BLOCK_SIZE / 2)

	setPalette();
	pass # Replace with function body.

func setPalette():
	
	var bright_color;
	var middle_color;
	var dark_color;
	
	var blockMaterial = ShaderMaterial.new();
	var blockShader = BLOCK_SHADER;
	
	if(palette == 1):
		bright_color = Color(0.6118, 0.9882, 0.9412, 1);
		middle_color = Color(0, 0.5020, 0.5333, 1);
		dark_color = Color(0,0,0,1);
	elif(palette == 2 || palette == 3):
		bright_color = Color(1, 1, 1, 1);
		middle_color = Color(0.678, 0.678, 0.678, 1);
		dark_color = Color(0.3882,0.3882,0.3882,1);
	elif(palette == 4):
		bright_color = Color(1, 1, 1, 1);
		middle_color = Color(0.5647, 0.8784, 0.9098, 1);
		dark_color = Color(0, 0.2824, 0.7216,1);
	elif(palette == 5):
		bright_color = Color(0.7490, 0.9725, 0.6784, 1);
		middle_color = Color(0.1412, 0.5922, 0, 1);
		dark_color = Color(0,0,0,1);
	
	blockMaterial.shader = blockShader;
	
	blockMaterial.set_shader_param("color1", bright_color);
	blockMaterial.set_shader_param("color2", middle_color);
	blockMaterial.set_shader_param("color3",dark_color);

	if(palette != 0 && palette != 6):
		$MatrixSprite.call_deferred("set_material", blockMaterial);
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
