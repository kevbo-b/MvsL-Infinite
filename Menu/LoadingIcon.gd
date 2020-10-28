extends HBoxContainer

const LUIGI_SHADER = preload("res://Shader/luigi.shader");	
const STARMAN_SHADER = preload("res://Shader/starMan.shader");

func _ready():
	var gen = RandomNumberGenerator.new();

	gen.randomize();
	if(gen.randf() > 0.6):
		$SpriteLabel/MarioSprite.set_animation("walk2");
		
	gen.randomize();
	var num = gen.randf();
	
	var playerShader;
	var playerMaterial = ShaderMaterial.new();
	
	if(num > 0.6):
		playerShader = LUIGI_SHADER;
	elif(num < 0.1):
		playerShader = STARMAN_SHADER;
		
	playerMaterial.shader = playerShader;
	$SpriteLabel/MarioSprite.material = playerMaterial;
	pass # Replace with function body.

func _on_Skip_timeout():
	$Skip.stop();
	
	$Dots.text += ".";
	
	if($Dots.text.length() > 3):
		$Dots.text = "";

	$SpriteLabel/MarioSprite.set_frame($SpriteLabel/MarioSprite.get_frame() + 1);
	if($SpriteLabel/MarioSprite.get_frame() >= 3):
		$SpriteLabel/MarioSprite.set_frame(0);
	
	$Skip.start();
	pass # Replace with function body.
