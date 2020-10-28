extends SMBObjectBaseClass
class_name BigStar

const SOUND_STAR_APPEAR = preload("res://SFX/NSMB/star_appear_NSMB.wav");
const SOUND_STAR_GET = preload("res://SFX/NSMB/star_get_NSMB.wav");
const SOUND_STAR_DENIED = preload("res://SFX/NSMB/star_denied_NSMB.wav");

const IN_WALL_CHECKER = preload("res://Misc/InWallChecker.tscn");

const PARTICLE_EFFECT = preload("res://Misc/BigStarParticle.tscn");
var star_speed = 13;
const MAX_Y_SPEED = 60;
const is_loose = false;
var rotation_speed = 0.04;
var spawned_from_player = false;
var direction = 1;
var collected = false;
var bouncing = false;
var firstTime = true;
var flip = true;

var default_collision_layer_kinematic = 0;
var default_collision_layer_hitbox = 0;
var default_collision_mask_kinematic = 0;
var default_collision_mask_hitbox = 0;

func _ready():
	save_area2d_default_collisions($Area2D);
	save_default_collisions();
	if(!spawned_from_player):
		spawn();
	else:
		spawn_star_from_player(flip);
	pass

func _physics_process(delta):
	if(spawned_from_player):
		if(is_on_wall()):
			if(direction == 1):
				direction = -1;
				rotation_speed = -0.04;
			else:
				direction = 1;
				rotation_speed = 0.04;
			checkIfInsideWall(true);
		
		motion.x = star_speed * MASS_MULTIPLICATOR * direction;
		motion.y += (GRAVITY + 4);
		motion.y = min(motion.y, MAX_Y_SPEED * MASS_MULTIPLICATOR);
		$Area2D/BigStarSprite.rotate(rotation_speed);
		
		if(is_on_floor()):
			motion.y = -54 * MASS_MULTIPLICATOR;
	motion = move_and_slide(motion, DEFAULT_UP);
	
	check_if_out_of_bounds();
	pass
	
func spawn_star_from_player(flipStar):
	playFromChannel(-1, SOUND_STAR_APPEAR, 2);
	
	$CollisionShape.disabled = false;
	save_area2d_default_collisions($Area2D);
	save_default_collisions();
	bouncing = true;
	motion.y = -100 * MASS_MULTIPLICATOR;
	
	if(flipStar == false):
		rotation_speed = -0.04;
		direction = -1;
	else:
		rotation_speed = 0.04;
		direction = 1;
		
	set_all_collisions(false);
	$DisabledCollisionTime.start();
	pass

func get_number_of_spawning_positions():
	return get_parent().get_child_count() - 1;
	pass

func spawn():
	
	call_deferred("showDirectionToPlayers");
	
	if(!firstTime):
		playFromChannel(-1, SOUND_STAR_APPEAR, 2);
		
	var amount_pos = get_number_of_spawning_positions();
	
	randomize();
	var random_pos = rand_range(1.0, amount_pos + 0.99);
	random_pos = int(random_pos);
	
	var path_star = get_parent().get_path();
	var spawn_point = get_node(str(path_star) + "/BigStarPosition" + str(random_pos))
	position.x = spawn_point.position.x;
	position.y = spawn_point.position.y;
	show();
	$Area2D/BigStarSprite.set_animation("appear");
	firstTime = false;
	
	yield($Area2D/BigStarSprite,"animation_finished");
	$Area2D/BigStarSprite.set_animation("default");
	collected = false;
	set_all_collisions(true);

	pass

func _on_Area2D_body_entered(body):
	if "player" in body.name:
		if(collected == false):
			collected = true;
			spawnParticle();
			if(bouncing):
				playFromChannel(-1, SOUND_STAR_DENIED, 2);
				
				body.big_star_collected();
				queue_free();
			else:
				playFromChannel(-1, SOUND_STAR_GET, 2);
				
				set_all_collisions(false);
				hide();
				body.big_star_collected();
				rebuild_world();
				$RespawnTimer.start();
	pass
	
func spawnParticle():
	var particle = PARTICLE_EFFECT.instance();
	particle.position = position;
	get_parent().add_child(particle);
	pass

func rebuild_world():
	rebuild_coins();
	rebuild_blocks();
	rebuild_enemies();
	
	rebuild3DBlocks();
	#respawn all breakable blocks, coins, enemies
	pass

func rebuild_coins():
	var coins = get_parent().get_parent().get_node("Coins").get_children();
	
	for Coin in coins:
		Coin.respawn();
	pass

func rebuild_blocks():
	var blocks = get_parent().get_parent().get_node("Blocks").get_children();
	
	for block in blocks:
		block.restore();
	pass
	
func rebuild_enemies():
	var enemies = get_parent().get_parent().get_node("Enemies").get_children();
	
	for Enemy in enemies:
		Enemy.setRespawnable();
	pass
	
func rebuild3DBlocks():
	if(Global.threeDMode):
		for path in Global.canvas3DPaths:
			get_node(path).restoreAllBlocks();
	pass

func _on_DisabledCollisionTime_timeout():
	$DisabledCollisionTime.stop();
	setArea2DCollision(true);
	var checker = IN_WALL_CHECKER.instance();
	checker.position.y = -8
	checker.setDoubleChecker(18);
	checker.setScanLength(20);
	call_deferred("add_child",checker);
	pass

func _on_RespawnTimer_timeout():
	$RespawnTimer.stop();
	spawn();
	pass
	
func got_hit_from_block(player = null):
	pass

func showDirectionToPlayers():
	get_parent().get_parent().get_node("player").get_node("DirectionArrowBigStar").starSpawned();
	if(Global.player_amount > 1):
		get_parent().get_parent().get_node("player2").get_node("DirectionArrowBigStar").starSpawned();
		if(Global.player_amount > 2):
			get_parent().get_parent().get_node("player3").get_node("DirectionArrowBigStar").starSpawned();
			if(Global.player_amount > 3):
				get_parent().get_parent().get_node("player4").get_node("DirectionArrowBigStar").starSpawned();
	pass
