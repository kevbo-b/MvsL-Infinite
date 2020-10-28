extends SMBObjectBaseClass
class_name BlockBreak

const SOUND_BLOCKBREAK = preload("res://SFX/8bitSMB/smb_breakblock.wav");

func _ready():
	get_node(Global.sfxC1_path).playSound(SOUND_BLOCKBREAK);
	initialize();
	pass # Replace with function body.

const SPEED_X = 12;
const BOUNCE_Y = -76;
const BOUNCE_ADD = 24; #for lower jump
var palette = 0;
var sprite;
var time = 0;

func initialize():
	if(!initialized):
		$Despawn.start();
		sprite = $Sprite;
		sprite.region_rect.position.y = palette * 8;
		initialized = true;
	pass
	
func _physics_process(delta):
	motion.y += (GRAVITY + 5);
	motion = move_and_slide(motion, DEFAULT_UP);
	
	time = time + delta;
	if(time > (4.0 / 60.0)):
		time = 0;
		if(sprite.region_rect.position.x >= 24):
			sprite.region_rect.position.x = 0;
		else:
			sprite.region_rect.position.x = sprite.region_rect.position.x + 8;
			
	check_if_out_of_bounds();	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Despawn_timeout():
	$Despawn.stop();
	queue_free();
	pass
