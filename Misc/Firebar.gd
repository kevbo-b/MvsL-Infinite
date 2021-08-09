extends SMBObjectBaseClass

export var barSize = 6; #Big = 12
export var spinClockwise = true;
export var speedMultiplier = 1.0;
export var asFallingBlock = false;
export var onlySolidToMovingPlatform = false;

var time = 0;
var spinDirection = 1;

func _ready():
	initialize();
	pass # Replace with function body.

func initialize():
	if(!initialized):
		$Fire/FireSprite.position.x = (barSize * 8) / 2 - 4;
		$Fire/FireSprite.region_rect.size.x = barSize * 8;
		$Fire/FireCollision.position = $Fire/FireSprite.position;
		$Fire/FireCollision.scale.x = barSize * 0.4;
		if(asFallingBlock):
			$KinematicCollision.disabled = false;
			$BlockSprite.show();
			if(onlySolidToMovingPlatform):
				set_collision_layer_bit(0, false);
				set_collision_mask_bit(0, false);
		if(!spinClockwise):
			spinDirection = -1;
		initialized = false;
	pass

func _process(delta):
	$Fire.rotate(2.0 * PI / 60.0 / 3.4 * speedMultiplier * spinDirection);
	
	if(asFallingBlock):
		motion.y += GRAVITY;
		motion = move_and_slide(motion, DEFAULT_UP);
		check_if_out_of_bounds();
	
	time = time + delta;
	
	if(time > (4.0 / 60.0)):
		time = 0;
		$Fire/FireSprite.region_rect.position.y = $Fire/FireSprite.region_rect.position.y + 8;
		if($Fire/FireSprite.region_rect.position.y > 24):
			$Fire/FireSprite.region_rect.position.y = 0;
	pass
	
func despawn():
	pass
	
func respawn():
	pass

func get_class(): #Just so the player recognizes it as a damaging object
	return "EnemyBaseClass";
	pass

func _on_Fire_area_entered(area):
	if("player_hitbox" in area.name):
		if(!area.get_parent().have_star && !area.get_parent().isMega):
			area.get_parent().damaged(self);
	pass
