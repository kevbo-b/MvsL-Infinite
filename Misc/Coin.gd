extends SMBObjectBaseClass
class_name Coin

const c_counter = preload("res://Misc/CoinCounter.tscn");

var collected = false;
var box_spawned = false;
var enemyDropped = false;
var hit_player;
var hit_by_neutral = false;
var direction = 1;

var coinJumpUpwards = true;

var xSpeed = 0;

var palette = 0;

func _ready():
	save_area2d_default_collisions($CollectArea);
	save_default_collisions();
	setPaletteShader();
	if(box_spawned):
		$FromBoxDespawn.start();
	elif(enemyDropped):
		$EnemyDropTimer1.start();
	pass
	
func _physics_process(delta):
	if(box_spawned || enemyDropped):
		if(coinJumpUpwards):
			motion.y += GRAVITY;
		else:
			motion.y -= GRAVITY;
		if(enemyDropped):
			if(is_on_wall()):
				direction = direction * -1;
				checkIfInsideWall();
			elif(is_on_floor()):
				xSpeed = 0;
			motion.x = xSpeed * direction;
		motion = move_and_slide(motion, DEFAULT_UP);
		check_if_out_of_bounds();
	pass

func _on_CollectArea_body_entered(body):
	if "player" in body.name:
		if(collected == false):
			collected = true;
			hit_player = body;
			add_to_coin_counter();
			body.playCoinSound();
			checkIf3D();
			despawn();
	pass

func respawn():
	if(despawned):
		show();
		collected = false;
		set_all_collisions(true);
		despawned = false;
	pass

func setRespawnable(): #big star finds enemy dropped coins
	pass
	
func spawn_from_box(body, upwards = true):
	if(!(body == null)):
		if("player" in body.name):
			hit_player = body;
	else:
		hit_by_neutral = true;
	if(!hit_by_neutral):
		body.playCoinSound();
	coinJumpUpwards = upwards;
	save_area2d_default_collisions($CollectArea);
	set_all_collisions(false);
	$CollectArea/CoinSprite.play("coin_spin");
	position.x = position.x - 8;
	position.y = position.y - 28;
	box_spawned = true;
	#$FromBoxDespawn.start();
	pass
	
func despawn():
	if(enemyDropped):
		queue_free();
	hide();
	set_all_collisions(false);
	despawned = true;
	#refreshAreaInLayerBits($CollectArea, [5]);
	#refreshAreaInMaskBits($CollectArea, [1]);
	pass

func add_to_coin_counter():
	var count = c_counter.instance();
	
	if(!hit_by_neutral):
		hit_player.coin_collected();
		count.position.x = position.x + 4;
		count.position.y = position.y - 8;
		count.set_count(hit_player.coin_count + 1);
	else:
		count.position.x = position.x + 4;
		count.position.y = position.y - 8;
		count.set_count(0);
	get_parent().get_parent().call_deferred("add_child", count);
	pass
	
func droppedFromEnemy(pos):
	set_collision_mask_bit(0, true);
	set_collision_mask_bit(6, true);
	position = Vector2(pos.x - 8,pos.y - 8);
	randomize();
	motion.y = -30 * MASS_MULTIPLICATOR;
	xSpeed = 	rand_range(-20.0 * MASS_MULTIPLICATOR, 20.0 * MASS_MULTIPLICATOR);
	enemyDropped = true;
	$CollectArea/CoinSprite.set_animation("coin_dropped");
	pass

func _on_FromBoxDespawn_timeout():
	$FromBoxDespawn.stop();
	add_to_coin_counter();
	queue_free();
	pass


func _on_EnemyDropTimer1_timeout():
	$EnemyDropTimer1.stop();
	var alphaShader;
	var alphaMaterial = ShaderMaterial.new();
	alphaShader = load("res://Shader/alphaPuls.shader");

	alphaMaterial.shader = alphaShader;
	$CollectArea/CoinSprite.material = alphaMaterial;
	$EnemyDropTimer2.start();
	pass

func _on_EnemyDropTimer2_timeout():
	$EnemyDropTimer2.stop();
	queue_free();
	pass
	
func got_hit_from_block(player = null):
	if(!despawned):
		if(player == null):
			hit_by_neutral = true;
		else:
			hit_player = player;
			player.playCoinSound();
		add_to_coin_counter();
		checkIf3D();
		despawn();
	pass

func setPaletteShader():
	if(palette != 0 && palette != 5):
		var coinShader;
		var coinMaterial = ShaderMaterial.new();	
		if(palette == 1):
			coinShader = load("res://Shader/coinShader/coinUnderground.shader");	
		elif(palette == 2 || palette == 3):
			coinShader = load("res://Shader/coinShader/coinGrey.shader");	
		elif(palette == 4):
			coinShader = load("res://Shader/coinShader/coinIce.shader");	
		coinMaterial.shader = coinShader;
		$CollectArea/CoinSprite.material = coinMaterial;
	pass
	
func checkIf3D():
	if(Global.threeDMode):
		for path in Global.canvas3DPaths:
			get_node(path).deleteInteractiveBlock((position.x / 16),(position.y / 16));
	pass
