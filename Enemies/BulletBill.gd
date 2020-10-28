extends EnemyBaseClass
class_name BulletBill

var speed = -20;

export var motion_horizontally = 1.0; #Just as Multiplicator
export var motion_vertically = 0.0;

var kill_horizontally = false;

func _ready():
	save_area2d_default_collisions($enemie_hitbox);
	enemySprite = $Sprite;
	set_sprite_direction();
	if(!spawned_from_generator):
		motion_horizontally = abs(motion_horizontally);
		spawnOnSight();
	pass
	
func setPalette():
	$Sprite.region_rect.position.y = palette * 16;
	pass
	
func set_sprite_direction():
	var flip_multiplier = 1;
	if(motion_horizontally < 0):
		$Sprite.flip_h = true;
		flip_multiplier = -1;
	else:
		$Sprite.flip_h = false;
	
	if(motion_horizontally != 0 && motion_vertically != 0):
		if(motion_vertically > 0):
			$Sprite.rotation_degrees = flip_multiplier * 45;
		else:
			$Sprite.rotation_degrees = flip_multiplier * -45;
	else:
		if(motion_vertically > 0):
			$Sprite.rotation_degrees = 90;
			kill_horizontally = true;
		elif(motion_vertically < 0):
			kill_horizontally = true;
			$Sprite.rotation_degrees = -90;
	pass
	
func _physics_process(delta):
	if(!despawned):
		if(is_dead):
			motion.y += GRAVITY;
		else:
			motion.y = speed * motion_vertically * MASS_MULTIPLICATOR;
		
		motion.x = speed * motion_horizontally * MASS_MULTIPLICATOR;
			
		motion = move_and_slide(motion, DEFAULT_UP);
		
		check_if_out_of_bounds();
	checkIfInPlayerReach();
	pass
	
func reset_visually():
	$Sprite.flip_h = true;
	if(kill_horizontally):
		$Sprite.flip_h = false;
	else:
		$Sprite.flip_v = false;
	motion_horizontally = -1;
	pass
	
func is_shot(body, shooter):
	if(body.get_class() == "ThrowingHammer"): #only with hammers...
		playEnemySFX(SOUND_KICKED);
		dead();
	pass
	
func dead():
	if(!is_dead):
		set_all_collisions(false);
		is_dead = true;
		if(kill_horizontally):
			$Sprite.flip_h = true;
		else:
			$Sprite.flip_v = true;
		enemy_fall = true;
	pass

func squished(body):
	body.jump_off_enemy(self);
	dead();
	pass

func changeDirection(extraChecks = true):
	motion_horizontally = motion_horizontally * -1;
	set_sprite_direction();
	pass
	
func inHitbox(player):
	_on_enemie_hitbox_area_entered(player.get_node("player_hitbox"));
	pass

func _on_enemie_hitbox_area_entered(area): #Other method because of an Debugging Routine... but works the same.
	if "player_hitbox" in area.name:
		var body = area.get_parent();
		if(body.have_star || body.isMega):
			dead();
		else:
			if (isInPlayerRaycast(body, self)):
				if(body.item_state >= 0):
					squished(body);
				elif(body.stomping):
					squished(body);
					body.stopStomp(false, true);
				body.jump_off_enemy(self);
			else:
				body.damaged(self);
	pass


func get_class():
	return "BulletBill";
	pass
