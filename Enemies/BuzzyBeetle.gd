extends EnemyBaseClass
class_name BuzzyBeetle 
#Like KoopaGreen, but fireball controllable & ridable after
const SPEED = 12;
const DEAD_BOUNCE = -24;

var is_squished = false;
var is_kicked = false;
var speed_multiplier = 4;

var invincible_kicker = false;
var kicker;

func _ready():
	save_area2d_default_collisions($enemie_hitbox);
	if(!spawned_from_generator):
		spawnOnSight();
	pass

func _physics_process(delta):
	
	if(is_dead == false):
		if(is_on_wall()):
			changeDirection();

	if((!is_squished && !is_kicked) || hit_by_block):
		motion.x = SPEED * MASS_MULTIPLICATOR * direction;
	
	if(is_kicked):
		motion.x = SPEED * speed_multiplier * MASS_MULTIPLICATOR * direction;

	motion.y += GRAVITY;
	motion.y = min(motion.y, MAX_Y_FALL_SPEED * MASS_MULTIPLICATOR);
	
	if(!despawned):
		motion = move_and_slide(motion, DEFAULT_UP);
	
	if(hit_by_block):
		if(is_on_floor()):
			motion.x = 0;
			hit_by_block = false;
	
	checkIfInPlayerReach();
	checkIfSquished();
	check_if_out_of_bounds();
	
	pass

func check_collision_with_block():
	var colliding_block;
		
	$BlockHitRight1.force_raycast_update();
	$BlockHitRight2.force_raycast_update();
	$BlockHitLeft1.force_raycast_update();
	$BlockHitLeft2.force_raycast_update();
	
	if(direction == 1):
		if($BlockHitRight1.is_colliding()):
			colliding_block = $BlockHitRight1.get_collider();
		elif($BlockHitRight2.is_colliding()):
			colliding_block = $BlockHitRight2.get_collider();
	if(direction == -1):		
		if($BlockHitLeft1.is_colliding()):
			colliding_block = $BlockHitLeft1.get_collider();
		elif($BlockHitLeft2.is_colliding()):
			colliding_block = $BlockHitLeft2.get_collider();

	if(colliding_block != null):
		colliding_block = colliding_block.get_parent();
		if("Block" in colliding_block.name):
			colliding_block.hit_by_enemy(self, kicker);
	pass
	
func reset_visually():
	$SquishedTimer.stop();
	$InvincibleToPlayerAfterKick.stop();
	invincible_kicker = false;
	is_kicked = false;
	is_squished = false;
	direction = 1;
	$BuzzyBeetleSprite.flip_h = false;
	$BuzzyBeetleSprite.set_animation("walk");
	$FlatOnTop.set_collision_mask_bit(1, false);
	pass
	
func changeDirection(extraChecks = true):
	if(is_kicked && extraChecks):
		playEnemySFX(SOUND_BUMP);
		check_collision_with_block();
	
	if(direction == 1):
		direction = -1;
		$BuzzyBeetleSprite.flip_h = true;
	else:
		direction = 1;
		$BuzzyBeetleSprite.flip_h = false;
	pass
	
func is_shot(body, shooter):
	if(body is Fireball):
		if(is_kicked):
			squished(body);
		elif(is_squished):
			var kickShellRight;
			if(body.direction < 0):
				kickShellRight = false;
			else:
				kickShellRight = true;
			kick(kickShellRight, shooter);
	elif(body is ThrowingHammer):
		dead();
	pass
	
func dead():
	playEnemySFX(SOUND_KICKED);
	
	is_dead = true;
	$BuzzyBeetleSprite.set_animation("dead");
	set_all_collisions(false);
	
	$SquishedTimer.stop();
	$InvincibleToPlayerAfterKick.stop();
	
	motion.y = DEAD_BOUNCE * MASS_MULTIPLICATOR;
	enemy_fall = true;
	$FlatOnTop.set_collision_mask_bit(1, false);
	pass
	
func got_hit_from_block(hitter_player = null):
	motion.y = - 40 * MASS_MULTIPLICATOR;
	$SquishedTimer.stop();
	$SquishedTimer.start();
	$BuzzyBeetleSprite.set_animation("squished");
	$FlatOnTop.set_collision_mask_bit(1, false);
	is_squished = true;
	is_kicked = false;
	hit_by_block = true;
	pass
	
func squished(body):
	$BuzzyBeetleSprite.set_animation("squished");
	is_squished = true;
	is_kicked = false;
	$SquishedTimer.start();
	motion.x = 0;
	motion.y = 0;
	$FlatOnTop.set_collision_mask_bit(1, false);
	if("player" in body.name):
		if((body.stomping || body.stompSpinning) && body.item_state > -1):
			determineKick(body);
	pass

func kick(right, body):
	if(right && direction == -1):
		changeDirection();
	elif(!right && direction == 1):
		changeDirection();
		
	playEnemySFX(SOUND_KICKED);
	
	$FlatOnTop.set_collision_mask_bit(1, true);
	if("player" in body.name):
		kicker = body;
		invincible_kicker = true;
		$InvincibleToPlayerAfterKick.start();
			
		if(abs(body.motion.x) > 24 * MASS_MULTIPLICATOR || (body.stomping || body.stompSpinning)):
			speed_multiplier = 6;
		else:
			speed_multiplier = 4;
	else:
		pass
		#$PlayerStandOn.set_collision_mask_bit(1, true);
		#$PlayerStandOn.set_collision_layer_bit(0, true);
	
	$BuzzyBeetleSprite.set_animation("kicked");
	$SquishedTimer.stop();
	is_kicked = true;
	is_squished = false;

	pass


func _on_SquishedTimer_timeout():
	$SquishedTimer.stop();
	$BuzzyBeetleSprite.set_animation("walk");
	is_squished = false;
	pass

func _on_InvincibleToPlayerAfterKick_timeout():
	invincible_kicker = false;
	$InvincibleToPlayerAfterKick.stop();
	refreshAreaInMaskBits($enemie_hitbox, [1]);
	refreshAreaInLayerBits($enemie_hitbox, [3]);
	pass

func get_class():
	return "BuzzyBeetle";
	pass

func _on_enemie_hitbox_area_entered(area):
	if(area.get_parent() != self):
		var body = area.get_parent();
		if(body.get_class() == "Player"):
			if(body.isMega || body.have_star):
				self.dead();
			else:
				if(!invincible_kicker || kicker != body):
					if (isInPlayerRaycast(body, self)):
						if(!is_squished):
							if(body.item_state >= 0):
								squished(body);
							elif((body.stomping || body.stompSpinning)):
								squished(body);
								body.stopStomp(false, true);
							body.jump_off_enemy(self);
						else:
							determineKick(body);
					else:
						if(!is_squished):
							body.damaged(self);
						else:
							determineKick(body);
		elif(body is EnemyBaseClass):
			if(is_kicked):
				body.dead();
			else:
				changeDirection();
	
	pass
