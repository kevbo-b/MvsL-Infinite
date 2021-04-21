extends SMBObjectBaseClass
class_name SpawnPipe

#"res://SFX/8bitSMB/mb_Spawn.wav"
const SOUND_PIPE_SPAWN = preload("res://SFX/NSMB/pipe_spawn_NSMB.wav");

var original_position;
var rise_speed = -10;
var blinking = false;
var playSound = true;

func _ready():
	original_position = position;
	$BlinkTimer.start();
	playAudio();
	pass # Replace with function body.

func playAudio():
	if(Global.musicEnabled):
		playFromChannel(0, SOUND_PIPE_SPAWN);
	pass

func _physics_process(delta):
	if(position.y > original_position.y - 48):
		motion.y = rise_speed * MASS_MULTIPLICATOR;
		motion = move_and_slide(motion, DEFAULT_UP);
		position.y = max(original_position.y - 48, position.y);
		$StaticBody2D.constant_linear_velocity = Vector2(0,abs(motion.y));
	else:
		position.y = original_position.y - 48;
		$StaticBody2D.constant_linear_velocity = Vector2(0,0);
	
	if(blinking):
		toggle_animation_on_off();
	
	pass

func toggle_animation_on_off():
	if($StaticBody2D/Sprite.modulate.a == 1):
		$StaticBody2D/Sprite.modulate.a = 0.1;
	else:
		$StaticBody2D/Sprite.modulate.a = 1;
	pass

func _on_BlinkTimer_timeout():
	$BlinkTimer.stop();
	blinking = true;
	$DespawnAfterBlink.start();
	pass


func _on_DespawnAfterBlink_timeout():
	$DespawnAfterBlink.stop();
	queue_free();
	pass
