extends ItemBaseClass
class_name FireFlower

func _ready():
	initVariables();
	pass
	
func initVariables():
	if(!initialized):
		save_default_collisions();
		save_area2d_default_collisions($Area2D);
		sprite = $Area2D/FlowerSprite;
		dropTimer = $DropSpawnTimer;
		initialized = true;
	pass

func _physics_process(delta):
	
	if(!spawning):
		if(!spawn_from_block):
			motion.y += GRAVITY;
			motion.y = min(motion.y, MAX_Y_SPEED * MASS_MULTIPLICATOR);
	else:
		position.x = player.position.x;
	
	motion = move_and_slide(motion, DEFAULT_UP);
	
	check_if_out_of_bounds();
		
	if(time >= 0.125):
		time = -0.125;
		if(spawning):
			toggle_sprite_on_off();
	else:
		time = time + delta;
	
	checkIfSquished();
	
	pass

func checkIfSquished():
	if(is_on_floor() || is_on_ceiling()):
		checkIfInsideWall();
	pass

func get_class():
	return "FireFlower";
	pass
