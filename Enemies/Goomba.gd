extends EnemyBaseClass
class_name Goomba

const SPEED = 10;
const DEAD_BOUNCE = -24;

var is_squished = false;

func _ready():
	save_area2d_default_collisions($enemie_hitbox);
	spawnOnSight();
	pass


func _physics_process(delta):
	if(is_dead == false):
		if(is_on_wall()):
			changeDirection();
	
	if(!is_squished):
	
		if(!despawned):
			motion.x = SPEED * MASS_MULTIPLICATOR * direction;
			motion.y += GRAVITY;
			motion.y = min(motion.y, MAX_Y_FALL_SPEED * MASS_MULTIPLICATOR);
		
		motion = move_and_slide(motion, DEFAULT_UP);
	
	
	checkIfInPlayerReach();
	checkIfSquished();
	check_if_out_of_bounds();
	pass
	
func reset_visually():
	$SquishedTimer.stop();
	is_squished = false;
	$GoombaSprite.flip_v = false;
	direction = 1;
	$GoombaSprite.flip_h = false;
	$GoombaSprite.set_animation("default");
	pass
	
func changeDirection(extraChecks = true):
	if(direction == 1):
		direction = -1;
		$GoombaSprite.flip_h = true;
	else:
		direction = 1;
		$GoombaSprite.flip_h = false;
	pass

func dead():
	playEnemySFX(SOUND_KICKED);

	is_dead = true;
	$GoombaSprite.flip_v = true;
	#$GoombaSprite.stop();
	set_all_collisions(false);
	motion.y = DEAD_BOUNCE * MASS_MULTIPLICATOR;
	enemy_fall = true;
	pass

func squished(body):
	if("player" in body.name):
		if((body.stomping || body.stompSpinning) && body.item_state > -1):
			dead();
		else:
			killSquish();
	else:
		killSquish();
	pass
	
func killSquish():
	set_all_collisions(false);
	$GoombaSprite.set_animation("squished");
	is_squished = true;
	motion.x = 0;
	motion.y = 0;
	$SquishedTimer.start();
	pass

func _on_SquishedTimer_timeout():
	despawn();
	pass

func get_class():
	return "Goomba";
	pass

func _on_enemie_hitbox_area_entered(area):
	if(area.get_parent() != self):
		var body = area.get_parent();
		if(body.get_class() == "Player"):
			if(body.isMega || body.have_star):
				self.dead();
			else:
				if (isInPlayerRaycast(body, self)):
					if(!is_squished):
						if(body.item_state >= 0):
							squished(body);
						elif((body.stomping || body.stompSpinning)):
							squished(body);
							body.stopStomp(false, true);
						body.jump_off_enemy(self);
				else:
					body.damaged(self);
		elif(body is EnemyBaseClass):
			changeDirection();
	pass # Replace with function body.
