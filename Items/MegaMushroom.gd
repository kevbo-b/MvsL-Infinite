extends ItemBaseClass
class_name MegaMushroom

const SHROOM_SPEED = 16;
const MEGA_SPAWN_SOUND = preload("res://SFX/NSMB/nsmb_megaShroom_Spawn.wav");

func _ready():
	initVariables();
	pass
	
func initVariables():
	if(!initialized):
		save_default_collisions();
		save_area2d_default_collisions($Area2D);
		sprite = $Area2D/MegaShroomSprite;
		dropTimer = $DropSpawnTimer;
		initialized = true;
	pass

func _physics_process(delta):

	if(direction == 0 && is_on_floor()):
		direction = 1;
	
	if(is_on_wall()):
		if(direction == 1):
			direction = -1;
			sprite.flip_h = true;
		else:
			direction = 1;
			sprite.flip_h = false;
		checkIfInsideWall();
	
	if(!spawning):
		if(!spawn_from_block):
			motion.x = SHROOM_SPEED * MASS_MULTIPLICATOR * direction;
			motion.y += GRAVITY;
			motion.y = min(motion.y, MAX_Y_SPEED * MASS_MULTIPLICATOR);
	else:
		position.x = player.position.x;
	
	motion = move_and_slide(motion, DEFAULT_UP);
	
	if(time >= 0.125):
		time = -0.125;
		if(spawning):
			toggle_sprite_on_off();
	else:
		time = time + delta;
	
	checkIfSquished();
	check_if_out_of_bounds();
	
	pass
	
func checkIfSquished():
	if(is_on_floor() || is_on_ceiling()):
		checkIfInsideWall();
	pass
	
func initWallCheckerUse():
	useWallChecker(-8, 18, true, 16.1);
	pass
	
func spawn_from_block(upwards = true):
	z_index = -2;
	$Area2D/MegaShroomSprite.set_animation("slideOutOfBox");
	$Area2D/MegaShroomSprite.play()
	
	playFromChannel(3, MEGA_SPAWN_SOUND, -1);
	
	spawn_from_block = true;
	initVariables();
	set_all_collisions(false);
	spawningIn = true;
	#dropTimer.start();
	motion.y = SPAWN_MOTION - 1.6; #never spawning downwards
	
	dropTimer.wait_time = 1.6;
	dropTimer.stop();
	dropTimer.start();
	pass

func get_class():
	return "MegaMushroom";
	pass
