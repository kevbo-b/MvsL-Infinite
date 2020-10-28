extends ItemBaseClass
class_name PowerStar

const H_SPEED = 16;
const V_JUMP = 50;

func _ready():
	initVariables();
	pass
	
func initVariables():
	if(!initialized):
		save_default_collisions();
		save_area2d_default_collisions($Area2D);
		sprite = $StarSprite;
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
			
	if(is_on_floor()):
		motion.y = V_JUMP * -1 * MASS_MULTIPLICATOR;
	
	if(!spawning):
		if(!spawn_from_block):
			motion.x = H_SPEED * MASS_MULTIPLICATOR * direction;
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

func get_class():
	return "PowerStar";
	pass
