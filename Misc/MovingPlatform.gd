extends SMBObjectBaseClass
class_name MovingPlatform

export(int, "Sinking","Falling","Back and Forth","Constantly Moving","Constantly on Touch") var PlatformType;
export var lostLevelsStyle = false;
export var v_speed = 10;
export var h_speed = 0;
export var platform_size = 6;

const MAX_LENGTH = 100;

func _ready():
	set_size();
	if(infinite_y_scroll):
		$StaticBody2D/Collision.one_way_collision_margin = 40
		var difference = 10
		level_boundary_rect.position.y = level_boundary_rect.position.y + difference;
		
	pass # Replace with function body.

func set_size():
	if(platform_size > MAX_LENGTH || platform_size <= 0):
		platform_size = MAX_LENGTH;
	$StaticBody2D/Collision.scale.x = 0.4 * platform_size;
	$StaticBody2D/Sprite.region_rect.size.x = 8 * platform_size;
	var regionY = 0;
	if(lostLevelsStyle):
		regionY = 8;
	$StaticBody2D/Sprite.region_rect.position.y = regionY;
	pass

func _physics_process(delta):
	motion.y = v_speed * MASS_MULTIPLICATOR;
	motion.x = h_speed * MASS_MULTIPLICATOR;
	motion = move_and_slide(motion, DEFAULT_UP);
	$StaticBody2D.constant_linear_velocity = Vector2(abs(motion.x),abs(motion.y));
	check_if_out_of_bounds(true);
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
