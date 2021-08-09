extends SMBObjectBaseClass
class_name Player
#needed to define the upper direction

#Physics Preset (original smb1)
const WALK_ACCELERATION = 1;
const MAX_X_WALK_SPEED = 24;
const MAX_X_RUN_SPEED = 40;
const MAX_Y_SPEED = 64;
#const WALK_ACCELERATION_MULTIPLICATOR = 0.675;
const JUMPING_HEIGHT = -64;
const DEAD_JUMP = -64;
const WALL_SLIDE_SPEED = 30;
#Button Preset (used to be constant)
var JUMP_BTN = "jump";
var RUN_BTN = "ui_select";
var SPIN_BTN = "ui_cancel"; #unused
var UP_BTN = "ui_up";
var DOWN_BTN = "ui_down";
var LEFT_BTN = "ui_left";
var RIGHT_BTN = "ui_right";
var SHOOT_BTN = "ui_shoot";
var PAUSE_BTN = "pause";

#Preloaded Scenes
const FIREBALL = preload("res://Misc/Projectiles/Fireball.tscn");
const THROWING_HAMMER = preload("res://Misc/Projectiles/Hammer.tscn");

const MUSHROOM = preload("res://Items/shroom.tscn");
const FIREFLOWER = preload("res://Items/FireFlower.tscn");
const MINI_MUSHROOM = preload("res://Items/MiniMushroom.tscn");
const POWERSTAR = preload("res://Items/PowerStar.tscn");
const MEGA_MUSHROOM = preload("res://Items/MegaMushroom.tscn");
const HAMMER_POWERUP = preload("res://Items/HammerPowerup.tscn")

const BIG_STAR = preload("res://Misc/BigStar.tscn");
const SPAWN_PIPE = preload("res://Misc/SpawnPipe.tscn");

#particles
const PUSHED_EFFECT = preload("res://Player/BouncedParticle.tscn");
const STAR_SPARKLE = preload("res://Player/StarSparkleParticle.tscn");
const STOMP_PARTICLE = preload("res://Player/StompParticles.tscn");
const WALLSLIDE_PARTICLE = preload("res://Player/WallSlideParticle.tscn");
const WALLJUMP_EXPLOSION = preload("res://Player/WalljumpExplosion.tscn");
const MEGA_GROW_EFFECT = preload("res://Player/megaGrowParticles.tscn");

const MAX_FIREBALLS = 2;
const MAX_THROW_HAMMERS = 2;

#Shaders
const LUIGI_SHADER = preload("res://Shader/luigi.shader");	
const PLAYER3_SHADER = preload("res://Shader/player3.shader");
const PLAYER4_SHADER = preload("res://Shader/player4.shader");	
const STARMAN_SHADER = preload("res://Shader/starMan.shader");	

#sounds
const SOUND_ONE_UP = preload("res://SFX/8bitSMB/smb_1-up.wav");
const SOUND_COIN = preload("res://SFX/8bitSMB/smb_coin.wav");
const SOUND_BUMP = preload("res://SFX/8bitSMB/smb_bump.wav");
const SOUND_FIREBALL = preload("res://SFX/8bitSMB/smb_fireball.wav");
const SOUND_JUMP_SMALL = preload("res://SFX/8bitSMB/smb_jump-small.wav");
const SOUND_JUMP_BIG = preload("res://SFX/8bitSMB/smb_jump-super.wav");
const SOUND_JUMP_MINI = preload("res://SFX/8bitSMB/custom_smb_jump-mini.wav");
const SOUND_WALLJUMP = preload("res://SFX/NSMB/walljump.wav");
const SOUND_DEAD = preload("res://SFX/8bitSMB/smb_mariodie.wav");
const SOUND_DEAD_SHORT = preload("res://SFX/8bitSMB/smb_mariodie_short.wav");
const SOUND_PIPE = preload("res://SFX/8bitSMB/smb_pipe.wav");
const SOUND_POWERUP_GROW = preload("res://SFX/8bitSMB/smb_powerup.wav");
const SOUND_MINISHROOM_GROW = preload("res://SFX/8bitSMB/custom_powerup_mini.wav");
const SOUND_MEGASHROOM_GROW = preload("res://SFX/NSMB/nsmb_megaShroom_grow.wav");
const SOUND_MEGASHROOM_SHRINK = preload("res://SFX/NSMB/nsmb_megaShrink.wav");
const SOUND_DROP_ITEM = preload("res://SFX/NSMB/nsmb_use_item.wav");
const SOUND_WALKED_PLAYER = preload("res://SFX/NSMB/nsmb_walking_enemy.wav");
const SOUND_JUMP_OFF_ENEMY = preload("res://SFX/8bitSMB/smb_stomp.wav");
const SOUND_JUMP_OFF_PLAYER = SOUND_JUMP_OFF_ENEMY;
const SOUND_STOMP = preload("res://SFX/NSMB/nsmb_stomp.wav");
const SOUND_STOMP_SWING = preload("res://SFX/NSMB/nsmb_stomp_swing.wav");
const SOUND_SAVE_ITEM = preload("res://SFX/NSMB/nsmb_saveItem.wav");
#const SOUND_LOOSE_STAR = preload();
var canSpawnWSParticle = false;

var firstTime = true; #for pipe invinciblity
var setInvincibleAfterPipe = true;

#motion for all tasks of the Player
var flip_sprite = false;
var win_num_stars;
var playerID = 1;

var is_dead = true;
var dead_gravity_disabled = false;
#mini shroom and star changes those
var gravity_multiplier = 1;
var jumpingHeight_multiplier = 1;
var maxYSpeed_multiplier = 1;
var maxXSpeed_multiplier = 1;

var megaDestructiveFallSpeed = 250;

var controlsSet = false; #even needed?

var slipFrictionDivisor = 6.0;

var sideways = false;
var sidewaysDirection = 0;
var old_position;
var deletedPlayer = false;

var can_walljump = false;
var stomping = false;
var stompSpinning = false;
var wallJumping = false;

var destinationSpawn : Position2D;
var pipeDestination : Rect2;
var pipeTravelSpeed = Vector2(6, 8);
var pipeInwards = false;
var interactingWithPipe = false;

var defaultUp;

var item_state = 0; #0 = small, 1=big, 2=fireflower, -1 = Mini shroom, 3 = Hammer, 5 = Mega
var old_item_state = 0;
var itemJustCollected = false;
var projectilesActive = 0;
var have_star = false;
var invincible = false;
var stunned = false;
var force_stun = false;
var bounced_on = false;
var shot_on = false; 
var walked_on = false;
var ignoredPlayer = null;
var ducked = false;
var isSlipping = false;
var isMega = false;
var isShooting = false;

var isOldItemState = false;
const growAnimationChanges = 12;
var growAnimationCount = 0;

var controls_off = false;
var stars = 0;

var idle_anim = "Idle";
var turn_anim = "Turn";
var run_anim = "Run";
var jump_anim = "Jump";
var duck_anim = "Duck";
var stun_anim = "Stun";
var wallSlide_anim = "WallSlide";
var stomp_anim = "Stomp";
var hud_path = "HUD";
var cam_path = "PlayerCamera";
var scene_path = "";
var generatedRandomShader = false;
var randomColors : Array;

var anim_extension = "";

var personal_name;
#for online
var is_local_player = true;

func _ready():
	defaultUp = DEFAULT_UP;
	old_position = position;
	Global.player_instances.append(self);
	save_default_collisions();
	save_area2d_default_collisions($player_hitbox);
	deleteNonexistentPlayers();
	#setPlayerID();
	setPlayerShader();
	setPlayerControls();
	win_num_stars = Global.stars_to_collect;
	
	var t = Timer.new() #so components can initiate before respawn, like HUD...
	t.set_wait_time(0.01)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free();
	
	savePlayerPositions();
	
	if(Global.is_vs_mode):
		respawn();
	else:
		is_dead = false;
		if(is_local_player):
			get_node(hud_path).initCoop();
			get_node(hud_path + "/Transition/FadeAnimationPlayer").play("Nothing");
	pass

func _physics_process(delta):
	
	var turn = false;
	var friction = false;
	var holding_down = false;
	ducked = false;
	var walkInputPressed = false;
	can_walljump = false;
	
	if(Global.is_online_mode):
		if(self.get_network_master() == get_tree().get_network_unique_id()):
			var btns = networkConstructPressedButtons();
			rpc("networkSetPressedButtons", btns);
	
	if(Input.is_action_pressed(PAUSE_BTN)):
		toggle_pause();
	
	if(!is_dead):
		if($SlipperyDetectionLeft.is_colliding() || $SlipperyDetectionRight.is_colliding()):
			setSlippery(true);
		else:
			setSlippery(false);
		
		if(Input.is_action_pressed(DOWN_BTN)): #to enter pipes
			holding_down = true;
		if(Input.is_action_pressed(RIGHT_BTN) && !stunned && !controls_off && !stompSpinning && !stomping && !wallJumping):
			walkInputPressed = true;
			flip_sprite = false;
			if(motion.x < 0):
				turn = true;
				if(!isSlipping):
					motion.x += MASS_MULTIPLICATOR * 2;
				else:
					motion.x += MASS_MULTIPLICATOR * 2 / (slipFrictionDivisor - 3.5);
			else:
				if(Input.is_action_pressed(RUN_BTN)):
					motion.x = min(motion.x + WALK_ACCELERATION * MASS_MULTIPLICATOR, MAX_X_RUN_SPEED * maxXSpeed_multiplier * MASS_MULTIPLICATOR);
				else:
					if(abs(motion.x) > MAX_X_WALK_SPEED * MASS_MULTIPLICATOR):
						motion.x -= MASS_MULTIPLICATOR;
					else:
						motion.x = min(motion.x + WALK_ACCELERATION * (MASS_MULTIPLICATOR * 0.675), MAX_X_WALK_SPEED * MASS_MULTIPLICATOR);
		elif(Input.is_action_pressed(LEFT_BTN) && !stunned && !controls_off && !stompSpinning && !stomping && !wallJumping):
			walkInputPressed = true;
			flip_sprite = true;
			if(motion.x > 0):
				turn = true;
				if(!isSlipping):
					motion.x -= MASS_MULTIPLICATOR * 2;
				else:
					motion.x -= MASS_MULTIPLICATOR * 2 / (slipFrictionDivisor - 3.5);
			else:
				if(Input.is_action_pressed(RUN_BTN)):
					motion.x = max(motion.x - WALK_ACCELERATION * MASS_MULTIPLICATOR, MAX_X_RUN_SPEED * maxXSpeed_multiplier * MASS_MULTIPLICATOR * (-1));
				else:
					if(abs(motion.x) > MAX_X_WALK_SPEED * MASS_MULTIPLICATOR):
						motion.x += MASS_MULTIPLICATOR;
					else:
						motion.x = max(motion.x - WALK_ACCELERATION * (MASS_MULTIPLICATOR * 0.675), MAX_X_WALK_SPEED * MASS_MULTIPLICATOR * (-1))
		else:
			friction = true;
			if(Input.is_action_pressed(DOWN_BTN) && !stunned && !isMega): #if exclusively pushing down_btn
				ducked = true;
	
		if(!Input.is_action_pressed(JUMP_BTN) && ("Jump" in $PlayerSprite.get_animation() || "Duck" in $PlayerSprite.get_animation())):
			motion.y += GRAVITY * 2.5 * gravity_multiplier * jumpingHeight_multiplier;	
		else:
			motion.y += GRAVITY * gravity_multiplier;
		
		if(isMega):
			setMegaDestructionBelow();
		
		if("Jump" in $PlayerSprite.get_animation() && !isShooting):
			$PlayerSprite.set_animation(jump_anim);
		if(ducked && is_on_floor()):
			checkForPipe(Vector2(0, 1));
		elif("Duck" in $PlayerSprite.get_animation()):
			set_duck_animation();
	
		if(is_on_ceiling() && !stompSpinning):
			playSFXAtChannel(1, SOUND_BUMP);
			if(Input.is_action_pressed(UP_BTN)):
				checkForPipe(Vector2(0, -1));
			$player_hitbox/RayCastCeilingLeft.force_raycast_update();
			$player_hitbox/RayCastCeilingRight.force_raycast_update();
			if($player_hitbox/RayCastCeilingLeft.is_colliding() || $player_hitbox/RayCastCeilingRight.is_colliding()):
				hit_touched_block();

		if(is_on_wall() || test_move(transform,Vector2(-1,0)) || test_move(transform,Vector2(1,0))):
			if(is_on_floor()):
				if(test_move(transform,Vector2(-1,0)) && Input.is_action_pressed(LEFT_BTN)):
					checkForPipe(Vector2(-1, 0));
				elif(test_move(transform,Vector2(1,0)) && Input.is_action_pressed(RIGHT_BTN)):
					checkForPipe(Vector2(1, 0));
			wallJumping = false;
			$WallJumpNoTurnBack.stop();
			if(item_state == -1 && is_on_floor() && false): #SIDEWAYS WALK IS BUGGY, TEMPORARY DISABLED
				sideways = true;
				if(motion.x >= 0):
					sidewaysDirection = -1;
					rotation_degrees = -90;
				else:
					sidewaysDirection = 1;
					rotation_degrees = 90;
			elif(!is_on_floor() && (motion.x != 0 || !$WallSlideStick.is_stopped()) && !isMega && !stomping && !stompSpinning && !stunned && Global.modern_movement):
				checkForWallJump();
		else:
			can_walljump = false;
			canSpawnWSParticle = false;
			$WallSlideParticleInterval.stop();
			defaultUp = Vector2(0,-1);
			sideways = false;
			rotation_degrees = 0;
		
		if(!is_on_floor() && Input.is_action_just_pressed(DOWN_BTN) && !stunned && !stompSpinning && !stomping && (Global.modern_movement || isMega)):
			stompAttack();
			
		if(Input.is_action_just_pressed(UP_BTN) && stomping):
			stopStomp(false, true); 
		
		if(can_walljump && Input.is_action_just_pressed(JUMP_BTN)):
			wallJump();
		
		elif(is_on_floor() && !interactingWithPipe):
			wallJumping = false;
			$WallJumpNoTurnBack.stop();
			$PlayerSprite.play();
			if(stomping):
				stopStomp(true, false);
			if(friction):
				if(motion.x < 0):
					if(!isSlipping):
						motion.x += MASS_MULTIPLICATOR;		
					else:
						motion.x += MASS_MULTIPLICATOR / slipFrictionDivisor;		
				elif(motion.x > 0):
					if(!isSlipping):
						motion.x -= MASS_MULTIPLICATOR;
					else:
						motion.x -= MASS_MULTIPLICATOR / slipFrictionDivisor;	
				if(abs(motion.x) <= 5):
					motion.x = 0;
			if(!stunned):
				if(ducked):
					set_duck_animation();
				elif("Duck" in $PlayerSprite.get_animation() || "Stomp" in $PlayerSprite.get_animation()):
					$PlayerSprite.set_animation(idle_anim);
					setItemStateEffect(item_state);
				elif(motion.x == 0):
					if(!isShooting):
						$PlayerSprite.set_animation(idle_anim);
				elif(turn && !isShooting):
					$PlayerSprite.set_animation(turn_anim);
				else:
					if(!isShooting):
						$PlayerSprite.set_animation(run_anim);
					if(abs(motion.x) < 14 * MASS_MULTIPLICATOR):
						$PlayerSprite.set_speed_scale(0.8);
					elif(abs(motion.x) >= 28 * MASS_MULTIPLICATOR):
						$PlayerSprite.set_speed_scale(3);
					else:
						$PlayerSprite.set_speed_scale(1.5);
					if(!walkInputPressed && isSlipping):
						$PlayerSprite.set_animation(idle_anim);
				if(Input.is_action_just_pressed(JUMP_BTN)):
					jump();
				set_looking_direction(flip_sprite);
				if(Global.is_online_mode && self.get_network_master() == get_tree().get_network_unique_id()):
					rpc("set_looking_direction", flip_sprite);

		elif(!interactingWithPipe):
			if(idle_anim in $PlayerSprite.get_animation() || turn_anim in $PlayerSprite.get_animation() || (can_walljump == false && wallSlide_anim in $PlayerSprite.get_animation())):
				$PlayerSprite.set_animation(jump_anim);
			if(!stompSpinning):
				$PlayerSprite.stop();
			motion.y = min(motion.y, MAX_Y_SPEED * MASS_MULTIPLICATOR * maxYSpeed_multiplier);
	
		if(!("Duck" in $PlayerSprite.get_animation()) && !("Stomp" in $PlayerSprite.get_animation()) && !("WallSlide" in $PlayerSprite.get_animation()) &&!stunned && !stompSpinning && !stomping):
			if(Input.is_action_just_pressed(SHOOT_BTN)):
				if(item_state >= 2 && item_state <= 3):
					shootProjectile();
			if(isShooting):
				setShootAnimation();
	
	elif(!dead_gravity_disabled):
		motion.y += GRAVITY;
	
	savePlayerPositions(!is_dead);
	
	if(interactingWithPipe):
		handlePipeInteraction();
	
#	if(is_on_floor()):
#		position.y = roundPosition(position.y); 
#	
#	if("player" == self.name):
#		print(str(position.y) + " ; " + str(motion.y));
	
	if(!stompSpinning):
		motion = move_and_slide(switchIfSideways(motion), defaultUp);
	
	if(invincible):
		 toggle_animation_on_off();

	if(stunned && motion.x == 0 && motion.y == 0 && !is_dead && is_on_floor() && !force_stun):
		stunned = false;
		setPlayerInvincible();
		$MaximumStunTimer.stop();

	if(!is_dead):
		checkIfInsideWall(true);
		check_if_out_of_bounds();
		
	if(Global.is_online_mode):
		doNetworking();
		
	pass
	
func jump(var sound = true):
	if(item_state == 0):
		setSFXAtChannel(1, SOUND_JUMP_SMALL);
	elif(item_state < 0):
		setSFXAtChannel(1, SOUND_JUMP_MINI);
	else:
		setSFXAtChannel(1, SOUND_JUMP_BIG);
		
	if(sound):
		startSFXAtChannel(1);
		
	if(abs(motion.x) <= 16 * MASS_MULTIPLICATOR):
		motion.y = JUMPING_HEIGHT * MASS_MULTIPLICATOR * jumpingHeight_multiplier;
	elif(abs(motion.x) > 24 * MASS_MULTIPLICATOR):
		motion.y = JUMPING_HEIGHT * MASS_MULTIPLICATOR * jumpingHeight_multiplier - 8 * MASS_MULTIPLICATOR;
	else:
		motion.y = JUMPING_HEIGHT * MASS_MULTIPLICATOR * jumpingHeight_multiplier - 4 * MASS_MULTIPLICATOR;
	if(!ducked):
		$PlayerSprite.set_animation(jump_anim);
	else:
		set_duck_animation(true);
	pass

func wallJump():
	setItemStateEffect(item_state);
	jump(false);
	
	var wjExplosion = WALLJUMP_EXPLOSION.instance();

	var dir = -1;
	if(test_move(transform,Vector2(-1,0))):
		dir = 1;
	else:
		wjExplosion.flip_h = true;
	
	if(item_state > 0):
		wjExplosion.offset = Vector2(position.x + 4 * dir, position.y - 8);
	elif(item_state == -1):
		wjExplosion.offset = Vector2(2 * position.x + 4 * dir, 2 * position.y);
		wjExplosion.scale = Vector2(0.5,0.5);
	else:
		wjExplosion.offset = Vector2(position.x + 4 * dir, position.y);
	
	motion.x = MAX_X_RUN_SPEED * MASS_MULTIPLICATOR * dir;
	$PlayerSprite.flip_h = !$PlayerSprite.flip_h;
	
	playSFXAtChannel(1, SOUND_WALLJUMP, 2);
	wallJumping = true;
	can_walljump = false;
	
	get_parent().add_child(wjExplosion);
	
	$WallJumpNoTurnBack.start();
	pass
	
func checkForWallJump():

	if(!$WallSlideStick.is_stopped() || (motion.x < 0 && Input.is_action_pressed(LEFT_BTN) && test_move(transform,Vector2(-1,0))) || (motion.x > 0 && Input.is_action_pressed(RIGHT_BTN) && test_move(transform,Vector2(1,0)))):
		can_walljump = true;		
		if(Input.is_action_pressed(RIGHT_BTN) || Input.is_action_pressed(LEFT_BTN)):
			$WallSlideStick.start();
		if(test_move(transform,Vector2(-2,0))):	
			$PlayerSprite.flip_h = true;
		else:
			$PlayerSprite.flip_h = false;		
		if(motion.y > 0):
			if(item_state > 0 && ("Duck" in $PlayerSprite.get_animation())):
				setItemStateEffect(item_state);
			$PlayerSprite.set_animation(wallSlide_anim + anim_extension);
			motion.y = min(motion.y,WALL_SLIDE_SPEED * MASS_MULTIPLICATOR);
			
			if($WallSlideParticleInterval.is_stopped()):
				$WallSlideParticleInterval.start();
			if(canSpawnWSParticle):
				var wsParticle = WALLSLIDE_PARTICLE.instance();
				wsParticle.position = position;
				
				var distance = 4;
				if(item_state == -1):
					wsParticle.process_material.scale = 0.5;
					distance = 2;
				
				if($PlayerSprite.flip_h):
					wsParticle.position.x += distance * -1;
				else:
					wsParticle.position.x += distance;
				
				get_parent().add_child(wsParticle);
				canSpawnWSParticle = false;
				
	pass

func stompAttack():
	motion.y = 0;
	motion.x = 0;
	$PlayerSprite.speed_scale = 1;
	$PlayerSprite.set_animation(stomp_anim ); #+ anim_extension
	playSFXAtChannel(3, SOUND_STOMP_SWING);
	$PlayerSprite.play();
	stompSpinning = true;

	if(item_state == 1 || item_state == 2 || item_state == 3):
		setItemStateEffect(0);

	$StompSpinTime.start();
	pass
	
func stopStomp(stopOnGround = true, forceStop = false):
	
	motion.y = min(motion.y, MAX_Y_SPEED * MASS_MULTIPLICATOR * maxYSpeed_multiplier);
	if(item_state == -1):
		maxYSpeed_multiplier = 0.70;
	else:
		maxYSpeed_multiplier = 1;
	stompSpinning = false;

	if(stopOnGround):
		createStompParticle();
		playSFXAtChannel(3, SOUND_STOMP);
		
		var blocks = [];
		
		$BlockStompLeft.force_raycast_update();
		$BlockStompRight.force_raycast_update();
		
		if($BlockStompLeft.is_colliding()):
			blocks += [$BlockStompLeft.get_collider()];
			
		if($BlockStompRight.is_colliding()):
			blocks += [$BlockStompRight.get_collider()];
	
		if(blocks.size() != 0):
			var stopAfterDestroy = false;
			for block in blocks:
				if("BlockArea" in block.name):
					if(item_state > 0):
						block.get_parent().stomped_on(self);
					else:
						block.get_parent().hit_by_player(self, false);
					if("Question" in block.get_parent().name || ("BrickBlock" in block.get_parent().name && block.get_parent().empty)):
						stopAfterDestroy = true;
				elif("DetectionArea" in block.name):
					block.get_parent().hit_by_player(self);
				elif(block.name == "PipeDetectableArea" || block.name == "EnterPipe"):
					stomping = false;
				if(item_state <= 0):
					stomping = false;
			if(stopAfterDestroy):
				stomping = false;
		else:
			stomping = false;
	 
	if(!stunned && (forceStop || !Input.is_action_pressed(DOWN_BTN) || Input.is_action_pressed(JUMP_BTN) || Input.is_action_pressed(LEFT_BTN) || Input.is_action_pressed(RIGHT_BTN))):
		stomping = false;
		$PlayerSprite.set_animation(run_anim);
		setItemStateEffect(item_state);
	pass
	
func checkForPipe(direction):
	var pipe;
	
	if($player_hitbox/PipeDetectionDown.is_colliding() && direction.y == 1):
		pipe = $player_hitbox/PipeDetectionDown.get_collider().get_parent().get_parent();
	elif($player_hitbox/PipeDetectionUp.is_colliding() && direction.y == -1):
		pipe = $player_hitbox/PipeDetectionUp.get_collider().get_parent().get_parent();
	elif($PipeDetectionRight.is_colliding() && direction.x == 1):
		pipe = $PipeDetectionRight.get_collider().get_parent().get_parent();
	elif($PipeDetectionLeft.is_colliding() && direction.x == -1):
		pipe = $PipeDetectionLeft.get_collider().get_parent().get_parent();
		
	if(pipe != null):
		if(pipe.maxEnterableState >= item_state && direction == pipe.direction && !isMega):
			enterPipe(pipe, direction);
	pass
	
func enterPipe(pipe, direction):
	var pipingLength = Vector2(24, 32);
	var pipePos = pipe.getEnteringCenter();
	destinationSpawn = get_node(Global.spawns_path).getDestinationBySpawnID(pipe.spawnID);
	
	if(pipe.isFastPipe):
		pipeTravelSpeed = Vector2(8 * 6, 8 * 6);
	else:
		pipeTravelSpeed = Vector2(6, 8);
	#The upcoming calculations look REALLY bad... But they work flawlessly
	if(pipe.isFastPipe || pipe.alwaysCenterPipeEntrancing):
		
		pipingLength = Vector2(pipe.getWarpLengthInTiles() * 16, pipe.getWarpLengthInTiles() * 16);
		
		if(!pipe.isFastPipe):
			pipingLength = Vector2(32, 32);

		var lengthAdd = getPipeEntranceHeight(item_state, direction);
		
		var length = pipingLength.y + lengthAdd + 8;
		
		if(direction.x != 0):
			pipingLength.x += lengthAdd;
			pipePos.y -= 8;
		if(direction.y > 0):
			pipingLength.y += lengthAdd;
		else:
			pipingLength.y += 8;
			
		if(direction.x != 0 && item_state == -1):
			length -= 4;
			if(pipe.isFastPipe):
				pipingLength.x -= 4;
				pipingLength.y -= 4;
		
		if(!pipe.isFastPipe):
			var shorten = 16;
			if(direction.y != 0 && item_state == -1):
				shorten = 8;
			pipingLength.x -= shorten;
			pipingLength.y -= shorten;
			length -= shorten;

		interactWithPipe(!pipe.isFastPipe, Vector2(pipePos.x + pipingLength.x * direction.x, pipePos.y + pipingLength.y * direction.y), direction, false, direction.x, false, true, length);
	else:
		interactWithPipe(true, Vector2(pipePos.x + pipingLength.x * direction.x, pipePos.y + pipingLength.y * direction.y), direction, false, direction.x, false, pipe.alwaysCenterPipeEntrancing);
	pass
	
func getPipeEntranceHeight(state, direction):
	var lengthAdd = 8;
	if(direction.y != 0):
		if(state < 0):
			lengthAdd = 0;
		elif(state > 0):
			if(direction.y < 0 && ducked):
				pass
			else:
				lengthAdd = 22;	
	return lengthAdd;
	pass

func dead_from_pit():
	if(isMega):
		if(!Global.is_vs_mode):
			get_node(Global.musicC1_path).stopMegaShroomTheme(self);
		$MegaShroomTimer.stop();
		$MegaShroomGlowTimer.stop();
		$AnimPlayer.stop();
		isMega = false;
	is_dead = true;
	loose_star(1);
	if(Global.is_online_mode && self.get_network_master() == get_tree().get_network_unique_id()):
		rpc("loose_star", 1);
	dead_gravity_disabled = true;
	set_all_collisions(false);
	motion.x = 0;
	$FullDeathTimer.start();
	decrementLive();
	play_dead_sound();
	pass
	
func play_dead_sound():
	if(!is_local_player || !Global.musicEnabled):
		setSFXAtChannel(2, SOUND_DEAD_SHORT);
		startSFXAtChannel(2);
	else:
	#if(Global.is_vs_moe):
		get_node(Global.musicC1_path).playerDied(self);
		
		#if(Global.musicEnabled): //now in global music node.
	#	setSFXAtChannel(2, SOUND_DEAD);
	#else:
	#	setSFXAtChannel(2, SOUND_DEAD_SHORT);
	#startSFXAtChannel(2);
	pass

func switchIfSideways(mot):
	if(sideways && false):
		var save = mot.x;
		mot.x = mot.y * sidewaysDirection * -1;
		mot.y = save * sidewaysDirection;
	return mot;
	pass
	
remote func set_looking_direction(flipSprite):
	if(flipSprite):
		$PlayerSprite.flip_h = true;
	else:
		$PlayerSprite.flip_h = false;
	pass
	
func setLocal(val):
	is_local_player = val;
	pass

func check_if_out_of_bounds(infiniteY = true, allowAboveScreen = true):
	
	if(position.y >= level_boundary_rect.end.y || position.y <  level_boundary_rect.position.y):
		if(infinite_y_scroll):
			if(position.y < level_boundary_rect.position.y):
				if(is_local_player):
					get_node(cam_path).adjustInfiniteWorldWarp(1);
				position.y = position.y + level_boundary_rect.size.y;
			else:
				if(is_local_player):
					get_node(cam_path).adjustInfiniteWorldWarp(2);
				position.y = position.y - level_boundary_rect.size.y;
		else:
			if(position.y >= level_boundary_rect.end.y):
				dead_from_pit();
	if(position.x > level_boundary_rect.end.x || position.x < level_boundary_rect.position.x):
		if(infinite_x_scroll):
			if(position.x < 0):
				if(is_local_player):
					get_node(cam_path).adjustInfiniteWorldWarp(3);
				position.x = position.x + level_boundary_rect.size.x;
			else:
				if(is_local_player):
					get_node(cam_path).adjustInfiniteWorldWarp(4);
				position.x = position.x - level_boundary_rect.size.x;

		else:
			dead_from_pit();
	pass

func respawn():
	if(!deletedPlayer):
		resetVariables();
		if(is_local_player):
			get_node(hud_path).transitionRespawn();
		have_star = false;
		isMega = false;
		$PlayerSprite.modulate = Color(1, 1, 1, 1);
		maxXSpeed_multiplier = 1;
		setPlayerShader();
		hide();
		is_dead = true;
		position = old_position;
		if(is_local_player):
			get_node(cam_path).resetCamera();
		savePlayerPositions();
		dead_gravity_disabled = true;
		motion.x = 0;
		motion.y = 0;
		item_state = 0;
		setItemStateEffect(0);
		setItemAnimation(0);
		var pipe = SPAWN_PIPE.instance();
		pipe.position = Vector2(position.x,position.y + 32);
		get_parent().call_deferred("add_child",pipe);
		$RespawnAfterPipeSpawn.start();
	pass
	
func interactWithPipe(inwards, EndOfPipePosition, direction, setInvincible, lookDirection = 0, blockPipeSound = false, centerEntrance = false, spawn_length = 32):
	#Entering and Exiting a Pipe (inwards true or false)
	if(direction.y == 0):
		$PlayerSprite.set_speed_scale(0.8);
		$PlayerSprite.play(run_anim);

	if(!inwards && direction.y != 0):
		$PlayerSprite.set_animation(idle_anim);
	elif(inwards && direction.y != 0):
		var currentAnim = $PlayerSprite.get_animation();
		if(currentAnim == jump_anim || currentAnim == stomp_anim):
			$PlayerSprite.set_animation(idle_anim);
	
	set_all_collisions(false);
	pipeInwards = inwards;
	z_index = -2;
	is_dead = true; #just so he cant move
	
	if(!inwards && lookDirection != 0):
		var lookLeft = false;
		if(lookDirection == -1):
			lookLeft = true;
		$PlayerSprite.flip_h = lookLeft;
		flip_sprite = lookLeft;
		
	resetVariables();
	if(!blockPipeSound):
		playSFXAtChannel(2, SOUND_PIPE);

	pipeDestination = Rect2(EndOfPipePosition.x, EndOfPipePosition.y, direction.x, direction.y);

	if(setInvincible):
		setInvincibleAfterPipe = true;
	else:
		setInvincibleAfterPipe = false;

	if(!inwards || centerEntrance):
		position = Vector2(EndOfPipePosition.x + (spawn_length * direction.x * -1), EndOfPipePosition.y + (spawn_length * direction.y * -1));
		if(!centerEntrance):
			if(is_local_player):
				get_node(cam_path).resetCamera();
	interactingWithPipe = true;
	motion.x = 0;
	motion.y = 0;
	
	savePlayerPositions();
	pass
	
func handlePipeInteraction():
	if(pipeDestination.size.y != 0):
		if(position.y > pipeDestination.position.y && pipeDestination.size.y < 0 || position.y < pipeDestination.position.y && pipeDestination.size.y > 0):
			motion.y = pipeDestination.size.y * pipeTravelSpeed.y * MASS_MULTIPLICATOR;
		else:
			stopPipeInteraction();
	elif(pipeDestination.size.x != 0):
		if(position.x > pipeDestination.position.x && pipeDestination.size.x < 0 || position.x < pipeDestination.position.x && pipeDestination.size.x > 0):
			motion.x = pipeDestination.size.x * pipeTravelSpeed.x * MASS_MULTIPLICATOR;
		else:
			stopPipeInteraction();
	pass
	
func stopPipeInteraction():
	if(pipeInwards):
		warpToDestination();
	else:
		z_index = 1;
		position.y = pipeDestination.position.y;
		position.x = pipeDestination.position.x;
		motion.y = 0;
		motion.x = 0;
		is_dead = false; #player can move again
		interactingWithPipe = false;
		set_all_collisions(true);
		if(setInvincibleAfterPipe):
			setPlayerInvincible();
	setItemStateEffect(item_state);
	pass
	
func warpToDestination():
	if(destinationSpawn.hasDestinationScene()):
		pass
	else:
		var type = destinationSpawn.spawnType;
		if(type == 0):
			position = destinationSpawn.position;
			respawn();
		elif(type == 1):
			position = destinationSpawn.position;
			respawn();
		elif(type == 2):
			position = destinationSpawn.position;
			respawn();
		elif(type == 3):
			interactWithPipe(false, destinationSpawn.position, Vector2(0, -1), false, 0);
		elif(type == 4):
			interactWithPipe(false, destinationSpawn.position, Vector2(0, 1), false, 0);
		elif(type == 5):
			interactWithPipe(false, destinationSpawn.position, Vector2(1, 0), false, 1);
		elif(type == 6):
			interactWithPipe(false, destinationSpawn.position, Vector2(-1, 0), false, -1);
	destinationSpawn = null;
	pipeInwards = false;
	pass
	
func _on_RespawnAfterPipeSpawn_timeout():
	show();
	$RespawnAfterPipeSpawn.stop();
	pipeTravelSpeed = Vector2(6, 8);
	if(firstTime):
		interactWithPipe(false, Vector2(old_position.x,old_position.y - 48), Vector2(0, -1), false, 1, (playerID != 1));
		firstTime = false;
	else:
		interactWithPipe(false, Vector2(old_position.x,old_position.y - 48), Vector2(0, -1), true, 1);
	
	if(Global.is_vs_mode): #Music reactivation
		var t = Timer.new()
		t.set_wait_time(0.7)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
	
		yield(t, "timeout")
		t.queue_free();
		get_node(Global.musicC1_path).playerRespawned(self);
	pass
	
func shootProjectile():
	
	var maxProjectiles;
	var projectile;
	var shootSound;
	
	if(item_state == 2):
		maxProjectiles = MAX_FIREBALLS;
		projectile = FIREBALL.instance();
		shootSound = SOUND_FIREBALL;
	elif(item_state == 3):
		maxProjectiles = MAX_THROW_HAMMERS;
		projectile = THROWING_HAMMER.instance();
		shootSound = SOUND_FIREBALL;
	
	if(projectilesActive < maxProjectiles):
		initiateShootAnimation();
		playSFXAtChannel(3, SOUND_FIREBALL, -1);
		projectilesActive += 1;
		projectile.initializeShot(self, $FireballPosition.global_position);
		get_parent().add_child(projectile);
	pass
	
func initiateShootAnimation():
	isShooting = true;
	$ShootAnimationDuration.stop();
	$ShootAnimationDuration.start();
	pass
	
func setShootAnimation():
	if(!("Shot" in $PlayerSprite.get_animation())):
		var frame = $PlayerSprite.get_frame();
		var old_anim = $PlayerSprite.get_animation();
		#if(!("Flower" in old_anim)):
		#	$PlayerSprite.set_animation("Idle_Flower");
		if("Flower" in old_anim || "Hammer" in old_anim):
			$PlayerSprite.set_animation(old_anim + "_Shot");
		if("Run" in old_anim):
			$PlayerSprite.set_frame(frame);
	pass
	
func setDestructiveMode(param):
	if(param == true):
		isMega = true;
		$player_hitbox.set_collision_mask_bit(0, true);
		if(!Global.is_vs_mode):
			get_node(Global.musicC1_path).playMegaShroomTheme(self);
	else:
		isMega = false;
		$player_hitbox.set_collision_mask_bit(0, false);
	pass
	
func setMegaDestructionBelow():
	if(motion.y >= megaDestructiveFallSpeed):
		if("Stomp" in $PlayerSprite.get_animation() && !stompSpinning):
			$player_hitbox.position = Vector2(0,-68); #STOMP
		else:
			$player_hitbox.position = Vector2(0,-81.6); #Regular Fall
	else:
		$player_hitbox.position = Vector2(0,-102);
	pass
	
func roundPosition(pos):
	if(int(round(pos)) - pos > 0.005):
		pos = int(round(pos));
	if("player" == self.name):
		print(int(round(pos)) - pos)
	return pos;
	pass
	
func saveItemToDropLater(item):
	setSFXAtChannel(2, SOUND_SAVE_ITEM, 3);
	print(self.name + " should save " + item.name);
	pass

func item_collected(item):
	itemJustCollected = true;
	setSFXAtChannel(2, SOUND_POWERUP_GROW, -2);
	if(isMega):
		saveItemToDropLater(item);
	elif(item.get_class() == "MegaMushroom"):
		setSFXAtChannel(2, SOUND_MEGASHROOM_GROW, 6);
		growToMega();
	elif(item_state != 5):
		if(item.get_class() == "MiniMushroom"):
			if(item_state != -1):
				set_item_state(-1);
				setSFXAtChannel(2, SOUND_MINISHROOM_GROW, -2);
			else:
				saveItemToDropLater(item);
		elif(item.get_class() == "Mushroom"):
			if(item_state <= 0):
				set_item_state(1);
			else:
				saveItemToDropLater(item);
		elif(item.get_class() == "PowerStar"):
			if(!have_star):
				maxXSpeed_multiplier = 1.2;
				have_star = true;
				#set star shader
				var playerShader;
				var playerMaterial = ShaderMaterial.new();	
				playerShader = STARMAN_SHADER;
				playerMaterial.shader = playerShader;
				$PlayerSprite.material = playerMaterial;
				#add star sparkle
				var sparkle = STAR_SPARKLE.instance();
				sparkle.position = self.position;
				sparkle.player = self;
				get_parent().add_child(sparkle);
			$PowerstarTimer.stop();
			$PowerstarTimer.start();
			
		elif(item.get_class() == "HammerPowerup"):
			if(item_state < 5 && item_state != 3):
				set_item_state(3);
			else:
				saveItemToDropLater(item);
		elif(item.get_class() == "FireFlower"):
			if(item_state < 5 && item_state != 2):
				set_item_state(2);
			else:
				saveItemToDropLater(item);

	
	startSFXAtChannel(2);
	pass
	
func drop_random_powerup():
	var diff = Global.current_max_stars - stars;
	
	var randomGen = RandomNumberGenerator.new();
	randomGen.randomize();
	
	var multiplicator = 5.0 / Global.stars_to_collect;

	var r = randomGen.randf_range(-1.0 + (diff * multiplicator),2 + (diff * multiplicator));

	playSFXAtChannel(0, SOUND_DROP_ITEM);
	
	var item_id = 0;
	
	if(r < 0.4):
		item_id = 1;
	elif(r >= 0.4 && r < 1.5):
		item_id = 2;
	elif(r >= 1.5 && r < 2.4):
		item_id = 3;
	elif(r >= 2.4 && r < 2.9):
		item_id = 4;
	elif(r >= 2.9 && r <= 3.8):
		item_id = 5;
	elif(r >= 3.8 && r <= 2 + (diff * multiplicator)):
		if(Global.level_spawns_mega_shroom):
			item_id = 6;
		else:
			item_id = 7;
	
	drop_powerup(item_id);
	if(Global.is_online_mode && self.get_network_master() == get_tree().get_network_unique_id()):
		rpc("drop_powerup", item_id);
	pass
	
remote func drop_powerup(item_id):
	var item = get_item_by_id(item_id);
	item.spawn_as_drop(self);
	get_parent().call_deferred("add_child", item);
	pass
		
func get_item_by_id(id):
	var item;
	
	if(id == 1):
		item = MUSHROOM.instance();
	elif(id == 2):
		item = FIREFLOWER.instance();
	elif(id == 3):
		item = MINI_MUSHROOM.instance();
	elif(id == 4):
		item = HAMMER_POWERUP.instance();
	elif(id == 5):
		item = POWERSTAR.instance();
	elif(id == 6):
		item = MEGA_MUSHROOM.instance();
	elif(id == 7):
		item = POWERSTAR.instance();
	else:
		item = MUSHROOM.instance();
		
	return item;
	pass

	
func playSFXAtChannel(channel, sound, db_add = 0):
	if(is_local_player || localPlayerNearby(position)):
		getAudioByChannel(channel).playSound(sound, db_add);
	pass
	
func setSFXAtChannel(channel, sound, db_add = 0):
	getAudioByChannel(channel).setSound(sound, db_add);
	pass
	
func startSFXAtChannel(channel):
	if(is_local_player || localPlayerNearby(position)):
		getAudioByChannel(channel).play();
	pass
	
func getAudioByChannel(channel):
	if(has_node("Audio" + str(channel))):
		return get_node("Audio" + str(channel));
	else:
		return $Audio0;
	pass
	
var coin_count = 0;

func coin_collected():
	
	var coins = coin_count + 1;
	
	if(Global.is_vs_mode):
		if(coins >= Global.max_coins):
			drop_random_powerup();
			coins = 0;
	elif(coins == 100):
		coins = 0;
		increaseLives();
		
	coin_count = coins;
	
	if(is_local_player):
		get_node(hud_path).setCoinCount(coins);
	pass
	
func increaseLives(amount = 1):
	playSFXAtChannel(0, SOUND_ONE_UP);
	if(is_local_player):
		get_node(hud_path).incrementLive(amount);
	pass
	
func resetVariables():
	can_walljump = false;
	stomping = false;
	stompSpinning = false;
	wallJumping = false;
	pass
	
func resetPlayerComponents():
	gravity_multiplier = 1;
	jumpingHeight_multiplier = 1;
	maxYSpeed_multiplier = 1;
	#maxXSpeed_multiplier = 1;
	$CollisionShape2D.scale = Vector2(0.8,0.9);
	$CollisionShape2D.position = Vector2(0,3.4);
	
	$player_hitbox.scale = Vector2(1,1);
	$player_hitbox.position = Vector2(0,2);

	$BlockStompRight.position = Vector2(10.4,0);
	$BlockStompLeft.position = Vector2(-10.4,0);
	#$player_hitbox/RayCastCeilingLeft.position = Vector2(-10.4,-13);
	#$player_hitbox/RayCastCeilingRight.position = Vector2(10.4,-13);
	$KickRayCastRightHigh.position = Vector2(14,-7);
	$KickRayCastRightLow.position = Vector2(14,10);
	$KickRayCastLeftHigh.position = Vector2(-14,-7);
	$KickRayCastLeftLow.position = Vector2(-14,10);
	$SlipperyDetectionLeft.position = Vector2(-11,0);
	$SlipperyDetectionRight.position = Vector2(11,0);
	
	#$PipeDetectionLeft.cast_to.x = -10;
	#$PipeDetectionRight.cast_to.x = 10;
	pass
	
remote func setItemStateEffect(new_state):
	if(new_state == 0):
		resetPlayerComponents();
	elif(new_state == -1): #mini
		$CollisionShape2D.scale = Vector2(0.4,0.45);
		$CollisionShape2D.position = Vector2(0,9.7);
		$player_hitbox.scale = Vector2(0.5,0.5);
		$player_hitbox.position = Vector2(0,9);

		$BlockStompRight.position = Vector2(5.2,0);
		$BlockStompLeft.position = Vector2(-5.2,0);
		
		$KickRayCastRightHigh.position = Vector2(7,4);
		$KickRayCastRightLow.position = Vector2(7,10);
		$KickRayCastLeftHigh.position = Vector2(-7,4);
		$KickRayCastLeftLow.position = Vector2(-7,10);
		
		$SlipperyDetectionLeft.position = Vector2(-7,0);
		$SlipperyDetectionRight.position = Vector2(7,0);

		gravity_multiplier = 0.4;
		jumpingHeight_multiplier = 0.62;
		maxYSpeed_multiplier = 0.70;
		motion.y = motion.y * (jumpingHeight_multiplier + 0.1);
	elif(new_state == 1 || new_state == 2 || new_state == 3):
		scale = Vector2(0.5,0.5);
		$CollisionShape2D.scale = Vector2(0.8,1.8);
		$CollisionShape2D.position = Vector2(0,-9.2);
		$player_hitbox.scale = Vector2(1,2);
		$player_hitbox.position = Vector2(0,-12);

		$BlockStompRight.position = Vector2(10.4,0);
		$BlockStompLeft.position = Vector2(-10.4,0);

		$KickRayCastRightHigh.position = Vector2(14,-30);
		$KickRayCastRightLow.position = Vector2(14,10);
		$KickRayCastLeftHigh.position = Vector2(-14,-30);
		$KickRayCastLeftLow.position = Vector2(-14,10);
		$SlipperyDetectionLeft.position = Vector2(-11,0);
		$SlipperyDetectionRight.position = Vector2(11,0);
		
		gravity_multiplier = 1;
		jumpingHeight_multiplier = 1;
		maxYSpeed_multiplier = 1;

	elif(new_state == 5): #mega
		$CollisionShape2D.scale = Vector2(2.8,6);
		$CollisionShape2D.position = Vector2(0,-68);
		$player_hitbox.scale = Vector2(4.0,7);

		$BlockStompRight.position = Vector2(45,0);
		$BlockStompLeft.position = Vector2(-45,0);

		$KickRayCastRightHigh.position = Vector2(55,-160);
		$KickRayCastRightLow.position = Vector2(55,10);
		$KickRayCastLeftHigh.position = Vector2(-55,-160);
		$KickRayCastLeftLow.position = Vector2(-55,10);
		$SlipperyDetectionLeft.position = Vector2(-25,0);
		$SlipperyDetectionRight.position = Vector2(25,0);

		jumpingHeight_multiplier = 1.1;
		gravity_multiplier = 1;
		jumpingHeight_multiplier = 1;
		maxYSpeed_multiplier = 1;
	itemJustCollected = false;
	pass
	
func reset_animations():
	$PlayerSprite.scale = Vector2(2,2);
	#$PlayerSprite.position.y = -16;
	idle_anim = "Idle";
	turn_anim = "Turn";
	run_anim = "Run";
	jump_anim = "Jump";
	duck_anim = "Duck";
	stun_anim = "Stun";
	wallSlide_anim = "WallSlide";
	stomp_anim = "Stomp";
	anim_extension = "";
	pass
	
func setItemAnimation(new_state):
	var frame = $PlayerSprite.get_frame();
	reset_animations();
	if(new_state == -1):
		$PlayerSprite.scale = Vector2(1,1);
		#$PlayerSprite.position.y = 0;
	elif(new_state == 1 || new_state == 5):
		anim_extension = "_Big";
		if(new_state == 5):
			$PlayerSprite.scale = Vector2(6,6);
			#$PlayerSprite.position.y = -80;
	elif(new_state == 2):
		anim_extension = "_Flower";
	elif(new_state == 3):
		anim_extension = "_Hammer";
		
	idle_anim = idle_anim + anim_extension;
	turn_anim = turn_anim + anim_extension;
	run_anim = run_anim + anim_extension;
	jump_anim = jump_anim + anim_extension;
	duck_anim = duck_anim + anim_extension;
	stun_anim = stun_anim + anim_extension;
	#wallSlide_anim + wallSlide_anim + anim_extension;
	stomp_anim = stomp_anim + anim_extension;
	
	$PlayerSprite.set_frame(frame);
	
	if(stunned):
		$PlayerSprite.set_animation(stun_anim);
	
	if("Stomp" in $PlayerSprite.get_animation() && !stompSpinning):
		$PlayerSprite.set_animation(stomp_anim);
		$PlayerSprite.set_frame(frame);
	#if(duck_anim in $PlayerSprite.get_animation()):
	#	$PlayerSprite.set_animation(jump_anim);
	pass
	
func growToNewAnimation(old_state, new_state):
	$ChangeBetweenAnimations.start();
	if(isOldItemState):
		setItemAnimation(old_state);
		isOldItemState = false;
	else:
		setItemAnimation(new_state);
		isOldItemState = true;
	
	pass
	
remote func set_item_state(new_state_number):
	old_item_state = item_state;
	item_state = new_state_number;

	setItemStateEffect(new_state_number);
	growToNewAnimation(old_item_state, new_state_number);
	pass
	
func set_duck_animation(ignoreStomp = false):
	if(!isMega && !stomping):
		if(!("Stomp" in $PlayerSprite.get_animation()) || ignoreStomp):
			$PlayerSprite.set_animation("Duck" + anim_extension);
	if(item_state == 1 || item_state == 2 || item_state == 3): #Flower and Big
		setItemStateEffect(0);
#	elif(isMega):
#		setItemStateEffect(6);
	pass
	
func toggle_animation_on_off():
	if($PlayerSprite.modulate.a == 1):
		$PlayerSprite.modulate.a = 0.3;
	else:
		$PlayerSprite.modulate.a = 1;
	pass

func conserve_item(item):
	pass;
	
func setLocalPlayer(val):
	is_local_player = val;
	if(is_local_player):
		Global.player_amount_local+=1;
	pass

func damaged(enemy):
	if(have_star || isMega):
		if!("player" in enemy.name):
			enemy.dead();
	elif(!invincible):
		loose_star(1);
		if(Global.is_online_mode && self.get_network_master() == get_tree().get_network_unique_id()):
			rpc("loose_star", 1);
		if(item_state <= 0):
				dead();
		else:
			playSFXAtChannel(2, SOUND_PIPE);
			setPlayerInvincible();
			if(item_state > 1 && item_state < 5):
				set_item_state(1);
			else:
				set_item_state(item_state - 1);
	pass

func dead(respawn = true):
	resetVariables();
	if(is_local_player):
		get_node(cam_path).stopCamera();
	if(isMega):
		if(!Global.is_vs_mode):
			get_node(Global.musicC1_path).stopMegaShroomTheme(self);
		$MegaShroomTimer.stop();
		$MegaShroomGlowTimer.stop();
		$AnimPlayer.stop();
		isMega = false;
		#$player_hitbox.set_collision_mask(area_2d_collision_mask);
			
	set_all_collisions(false);
	$PlayerSprite.set_animation("Dead");
	is_dead = true;
	sideways = false;
	dead_gravity_disabled = true;
	motion.x = 0;
	motion.y = 0;
	$DeathMoment.start();
	if(respawn):
		$FullDeathTimer.start();
	setPlayerShader();
	
	decrementLive();
	play_dead_sound();
	pass
	
func decrementLive(amount = 1):
	Global.playerLives[playerID - 1] -= amount;
	if(is_local_player):
		get_node(hud_path).decrementLive(amount);
	pass
	
func setPlayerInvincible():
	invincible = true;
	$InvincibleTimer.start();
	pass
	
func savePlayerPositions(setPos = true):
	if(setPos):
		Global.playerPositions[playerID - 1] = position;
	pass
	
func _on_DeathMoment_timeout():
	$DeathMoment.stop();
	dead_gravity_disabled = false;
	motion.y = DEAD_JUMP * MASS_MULTIPLICATOR;
	pass

func _on_FullDeathTimer_timeout():
	if(is_local_player):
		get_node(hud_path).transitionDead()
		yield(get_node(hud_path + "/Transition/FadeAnimationPlayer"), "animation_finished");
	$FullDeathTimer.stop();
	respawn();
	pass
	
func createStompParticle():
	var particle = STOMP_PARTICLE.instance();
	particle.position = Vector2(position.x, position.y + 8);
	if(isMega):
		particle.scale = Vector2(3,3);
	elif(item_state > -1):
		particle.scale = Vector2(1.5,1.5);
	get_parent().add_child(particle);
	pass
	
func createPlayerCollisionParticle():
	var particle = PUSHED_EFFECT.instance();
	var y_pos;
	if(item_state == -1):
		y_pos = position.y - 4;
	elif(item_state > 0):
		y_pos = position.y - 16;
	else:
		y_pos = position.y - 8;
	particle.position = Vector2(position.x, y_pos);
	get_parent().add_child(particle);
	pass

func getParticlePosition(add):
	var y_pos;
	if(item_state == -1):
		y_pos = position.y - 4 + add;
	elif(item_state > 0):
		y_pos = position.y - 16 + add;
	else:
		y_pos = position.y - 8 + add;
	return Vector2(position.x, y_pos);
	pass
		
func get_pushed(direction, x_speed, y_speed, stun, stomped = false):
	createPlayerCollisionParticle();
	
	if(ducked):
		setItemStateEffect(item_state);
		ducked = false;
	
	$PlayerSprite.set_animation(stun_anim);
	
	if(stomping || stompSpinning):
		stompSpinning = false;
		stomping = false;
		if(item_state == -1):
			maxYSpeed_multiplier = 0.70;
		else:
			maxYSpeed_multiplier = 1;
	
	if(stomped):
		loose_star(3);
		if(Global.is_online_mode && self.get_network_master() == get_tree().get_network_unique_id()):
			rpc("loose_star", 3);
	else:
		loose_star(1);
		if(Global.is_online_mode && self.get_network_master() == get_tree().get_network_unique_id()):
			rpc("loose_star", 1);
	playSFXAtChannel(2, SOUND_WALKED_PLAYER);
	
	motion.x = x_speed * MASS_MULTIPLICATOR * direction; #x_speed used to be 35
	motion.y = y_speed * MASS_MULTIPLICATOR;
	motion = move_and_slide(motion, defaultUp);
	
	if(stun == true):
		$PlayerSprite.set_animation(stun_anim);
		stunned = true;
		force_stun = true;
		$MinimumStunTimer.start();
		$MaximumStunTimer.start();
	pass
	
func won_game():
	get_node(scene_path).won_game(self);
	pass
	
func toggle_pause():
	get_node(scene_path).toggle_pause(self);
	pass

remote func loose_star(amount):
	#stars = max(0, stars - amount);
	
	var i = 0;
	while i < amount:
		if(stars > 0):
			stars = stars - 1;
			setGlobalCurrentStars(stars);
			if(is_local_player):
				get_node(hud_path).star_lost();
			var big = BIG_STAR.instance();
			big.position = Vector2(position.x, position.y);
			big.spawned_from_player = true;
			big.spawnerPlayerID = playerID;
			if(i == 1 || i == 2):
				big.flip = !$PlayerSprite.flip_h;
			else:
				big.flip = $PlayerSprite.flip_h;
			if(i == 1):
				big.star_speed = big.star_speed * 2;
			get_parent().call_deferred("add_child", big);
		i = i + 1;
	pass

func big_star_collected():
	stars = stars + 1;
	if(is_local_player):
		get_node(hud_path).star_collected();
	
	setGlobalCurrentStars(stars);
	
	if(stars >= win_num_stars):
		won_game();
	pass
	
func setGlobalCurrentStars(stars):
	if("2" in self.name):
		Global.player_current_stars[1] = stars;
	elif("3" in self.name):
		Global.player_current_stars[2] = stars;
	elif("4" in self.name):
		Global.player_current_stars[3] = stars;
	else:
		Global.player_current_stars[0] = stars;
	pass
	
func ignorePlayer(playerObj):
	ignoredPlayer = playerObj;
	$TempIgnorePlayer.start();
	pass

func got_bounced(direction, upperPlayer, stomped = false):
	self.ignorePlayer(upperPlayer);
	upperPlayer.ignorePlayer(self);
	
	bounced_on = true;
	if(stomped):
		if(item_state == -1):
			damaged(upperPlayer);
		else:
			get_pushed(direction, 45, MAX_Y_SPEED, true, true);
	else:
		get_pushed(direction, 35, MAX_Y_SPEED, true);
	pass
	
func got_walked(direction, ignoredPlayer):
	self.ignorePlayer(ignoredPlayer);
	ignoredPlayer.ignorePlayer(self);
	
	walked_on = true;
	get_pushed(direction, 20, -20, true);
	pass

func got_shot(direction, affectsCrouchedHammerSuit = false):
	if(ducked && item_state == 3 && !affectsCrouchedHammerSuit):
		pass
	elif(item_state == -1 && !invincible):
		loose_star(1);
		if(Global.is_online_mode && self.get_network_master() == get_tree().get_network_unique_id()):
			rpc("loose_star", 1);
		dead();
	else:
		if(!invincible && !shot_on):
			shot_on = true; 
			get_pushed(direction, 25, MAX_Y_SPEED, true);
	pass

func jump_off_enemy(enemy):
	if(stompSpinning && item_state == -1):
		stopStomp(false,true);
	if(!stomping && !stompSpinning):
		if(have_star):
			if "player" in enemy.name:
				enemy.damaged(self);
			else:
				enemy.dead();
		else:
			if(Input.is_action_pressed(JUMP_BTN)):
				motion.y = JUMPING_HEIGHT * MASS_MULTIPLICATOR * jumpingHeight_multiplier- 12 * MASS_MULTIPLICATOR;
			else:
				motion.y = -50 * MASS_MULTIPLICATOR;
			motion = move_and_slide(motion, DEFAULT_UP);
			if "player" in enemy.name:
				if(item_state == -1):
					setSFXAtChannel(1, SOUND_JUMP_OFF_ENEMY);
				else:
					setSFXAtChannel(1, SOUND_JUMP_OFF_ENEMY);
			else:
				setSFXAtChannel(1, SOUND_JUMP_OFF_ENEMY);
			startSFXAtChannel(1);
		if(!stunned && !(duck_anim in $PlayerSprite.get_animation())):
			$PlayerSprite.set_animation(jump_anim);
			$PlayerSprite.play();
	pass
	
func got_hit_from_block(hitter_player = null):
	if(!isMega && !have_star):
		if(!bounced_on):
			bounced_on = true;
			get_pushed(get_looking_direction() * -1, 10, -20, true);
	pass

func playCoinSound():
	playSFXAtChannel(4, SOUND_COIN, -3);
	pass
	
var refreshAfterInvincible = false;

func _on_InvincibleTimer_timeout():
	$InvincibleTimer.stop();
	
	bounced_on = false;
	shot_on = false;
	walked_on = false;
	
	refreshAreaInLayerBits($player_hitbox, [1]);
	refreshAreaInMaskBits($player_hitbox, [1, 3, 4]);
	
	var t = Timer.new()
	t.set_wait_time(0.02)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
	yield(t, "timeout")
	t.queue_free();	
	
	invincible = false;
	$PlayerSprite.modulate.a = 1;

	refreshAfterInvincible = true;
	$RefreshAfterInvincible.start();
	pass
	
func deleteNonexistentPlayers():
	if(self.name != "player"): #if not player 1
		if(int(self.name[6]) > Global.player_amount):
			queue_free();
			deletedPlayer = true;
	pass
	
func setPlayerShader():
	var randomColor = false;
	var playerShader;
	var playerMaterial = ShaderMaterial.new();
	if(self.name != "player"):
		if("2" in self.name):
			playerShader = LUIGI_SHADER;
			if(Global.DEBUG_LUIGI_NON_LOCAL):
				setLocalPlayer(false);
		elif("3" in self.name):
			playerShader = PLAYER3_SHADER;
		elif("4" in self.name):
			playerShader = PLAYER4_SHADER;
		else:
			playerShader = LUIGI_SHADER;
			randomColor = true;
	else:
		pass
		
	playerMaterial.shader = playerShader;

	if(randomColor):
		setRandomColorToPlayerShader(playerMaterial);

	$PlayerSprite.material = playerMaterial;
	pass
	
func setPlayerControls():
	if(!controlsSet):
		if(self.name != "player"):
			if("2" in self.name):
				set_controls_for_player(2);
			elif("3" in self.name):
				set_controls_for_player(3);
			elif("4" in self.name):
				set_controls_for_player(4);
		else:
			controlsSet = true;
	pass
	
func setRandomColorToPlayerShader(shaderMaterial):
	if(generatedRandomShader == false):
		var r = RandomNumberGenerator.new();
		r.randomize();
		for i in range(0,4):
			if(i % 2 == 0):
				randomColors.append(Color(r.randf(), r.randf(), r.randf(), 1));
			else:
				randomColors.append(Color(r.randf() * 0.7, r.randf() * 0.7, r.randf() * 0.7, 1));
		generatedRandomShader = true
	shaderMaterial.set_shader_param("newHatColor", randomColors[0]);
	shaderMaterial.set_shader_param("newShirtColor", randomColors[1]);
	shaderMaterial.set_shader_param("newFlowerHatColor", randomColors[2]);
	shaderMaterial.set_shader_param("newFlowerShirtColor", randomColors[3]);
	pass
	
func setPlayerID(num = -1):
	if(num != -1):
		playerID = num;
	else:
		#old, but still used ?
		if(self.name != "player"):
			if("2" in self.name):
				playerID = 2;
			elif("3" in self.name):
				playerID = 3;
			else:
				playerID = 4;
		else:
			playerID = 1;
	pass
	
func set_controls_for_player(player_number):
	var extension = "_p" + str(player_number);
		
	if(player_number == 1):
		resetControls();
	else:
		JUMP_BTN = JUMP_BTN + extension;
		RUN_BTN = RUN_BTN + extension;
		SPIN_BTN = SPIN_BTN + extension;
		UP_BTN = UP_BTN + extension;
		DOWN_BTN = DOWN_BTN + extension;
		LEFT_BTN = LEFT_BTN + extension;
		RIGHT_BTN = RIGHT_BTN + extension;
		SHOOT_BTN = SHOOT_BTN + extension;
	
	controlsSet = true;
	pass
	
func resetControls():
	JUMP_BTN = "jump";
	RUN_BTN = "ui_select";
	SPIN_BTN = "ui_cancel"; #unused
	UP_BTN = "ui_up";
	DOWN_BTN = "ui_down";
	LEFT_BTN = "ui_left";
	RIGHT_BTN = "ui_right";
	SHOOT_BTN = "ui_shoot";
	PAUSE_BTN = "pause";
	pass
	
func hit_touched_block():
	if($player_hitbox/RayCastCeilingLeft.is_colliding()):
		var blockLeft = $player_hitbox/RayCastCeilingLeft.get_collider().get_parent();
		if("Block" in blockLeft.name):
			blockLeft.hit_by_player(self);
		
	if($player_hitbox/RayCastCeilingRight.is_colliding()):
		var blockRight = $player_hitbox/RayCastCeilingRight.get_collider().get_parent();
		if("Block" in blockRight.name):
			blockRight.hit_by_player(self);
	pass
	
func setSlippery(param):
	if(param):
		if(!isSlipping):
			isSlipping = true;
	else:
		if(isSlipping):
			isSlipping = false;
	pass

func _on_MinimumStunTimer_timeout():
	$MinimumStunTimer.stop();
	force_stun = false;	
	pass
	
func get_looking_direction():
	if($PlayerSprite.flip_h):
		return -1;
	else:
		return 1;
	pass
	
func _on_player_hitbox_area_entered(area):
	var body;
	if(area.get_parent() != null):
		body = area.get_parent();
		if(body.get_class() == "Player" && ignoredPlayer != body && body != self):
			if((self.have_star || self.isMega) && !body.have_star && !body.invincible && !body.isMega):
				body.damaged(self);
				self.ignorePlayer(body);
				body.ignorePlayer(self);
			elif((body.have_star || body.isMega) && !self.have_star && !self.invincible && !self.isMega):
				self.damaged(self);
				self.ignorePlayer(body);
				body.ignorePlayer(self);
			else:
				var selfJumpOnLength = 6; #Has to be this much higher to count as a "Jumped on"
				var bodyJumpOnLength = 6; #these two get checked in "isInPlayerRaycast"
				
				if(body.item_state == -1):
					bodyJumpOnLength = 2;
					
				if(self.item_state == -1):
					selfJumpOnLength = 2;
					
				if(isMega): #mega
					selfJumpOnLength = 32;
				if(body.isMega):
					bodyJumpOnLength = 32;
					
				if(isInPlayerRaycast(self, body, bodyJumpOnLength)): #self is higher than body
					jump_off_enemy(body);
				elif(!invincible):
					if(!isInPlayerRaycast(body, self, selfJumpOnLength)): #body not higher than self, same height
						if(!body.invincible):
							var dir = 1;
							if(position.x < body.position.x):
								dir = -1;
							if(abs(body.motion.x - self.motion.x) > 24 * MASS_MULTIPLICATOR && is_on_floor() && body.is_on_floor()):
								if(!walked_on && body.item_state > -1 || item_state == -1):
									call_deferred("got_walked",dir, body);
							else: #walked, no stun
								if(is_on_floor() && body.is_on_floor() && self.item_state > -1):
									if(body.item_state > -1):
										motion.x = MAX_X_WALK_SPEED * MASS_MULTIPLICATOR * dir;
								else:
									motion.x = MAX_X_RUN_SPEED * MASS_MULTIPLICATOR * dir;
									createPlayerCollisionParticle();
					else: #body is higher than self
						if(!bounced_on && body.item_state > -1 || body.stomping || item_state == -1):
							call_deferred("got_bounced",get_looking_direction(),body,body.stomping);
							
		elif(!(body.get_class() == "Player")):
			if(isMega):
				if(body is SMBInteractiveBlocks || body is PawBlock || body is PowBlock):
					if(area.name != "HitAboveArea"):
						body.destroy_block(self);
				elif(body is SMBPipe):
					body.destroy_pipe(self);
					
	pass # Replace with function body.

func _on_player_hitbox_body_entered(body):

	pass

func _on_TempIgnorePlayer_timeout():
	$TempIgnorePlayer.stop();
	ignoredPlayer = null;
	pass

func _on_MaximumStunTimer_timeout():
	$MaximumStunTimer.stop();
	stunned = false;
	setPlayerInvincible();
	pass


func _on_ChangeBetweenAnimations_timeout():
	$ChangeBetweenAnimations.stop();
	if(growAnimationCount < growAnimationChanges):
		growAnimationCount += 1;
		growToNewAnimation(old_item_state, item_state);
	else:
		growAnimationCount = 0;
		$AnimPlayer.stop();
		setItemAnimation(item_state);
	pass
	
func growToMega():
	$ChangeBetweenAnimations.stop();
	$PlayerSprite.speed_scale = 1;
	$PlayerSprite.play("MegaShroomGrow");
	$AnimPlayer.play("MegaGrow");
	
	var mega_particles = MEGA_GROW_EFFECT.instance();
	mega_particles.position = Vector2(position.x, position.y + 8);
	get_parent().add_child(mega_particles);
	
	item_state = 54
	is_dead = true;
	dead_gravity_disabled = true;
	motion.y = 0;
	motion.x = 0;
	set_all_collisions(false);
	
	yield($AnimPlayer,"animation_finished");
	
	is_dead = false;
	dead_gravity_disabled = false; 
	set_all_collisions(true);
	setItemStateEffect(5);
	setItemAnimation(5);
	setDestructiveMode(true);
	
	$MegaShroomTimer.start();
	$MegaShroomGlowTimer.start();
	pass
	
func _on_MegaShroomTimer_timeout():
	$MegaShroomTimer.stop();
	setItemStateEffect(1);
	setItemAnimation(1);
	item_state = 1;
	setDestructiveMode(false);

	setPlayerInvincible();
	playSFXAtChannel(2, SOUND_MEGASHROOM_SHRINK, 6);
	$PlayerSprite.modulate = Color(1,1,1,1);
	$AnimPlayer.play_backwards("MegaGrow");
	pass
	
func _on_MegaShroomGlowTimer_timeout():
	$MegaShroomGlowTimer.stop();
	$AnimPlayer.play("MegaGlow");
	pass

func get_class():
	return "Player";
	pass

func _on_PowerstarTimer_timeout():
	$PowerstarTimer.stop();
	have_star = false;
	setPlayerShader();
	maxXSpeed_multiplier = 1;
	
	refreshAreaInMaskBits($player_hitbox, [1, 3, 4]);
	refreshAreaInLayerBits($player_hitbox, [1]);
	$RefreshAfterInvincible.start();
	refreshAfterInvincible = true;
	pass 


func _on_RefreshAfterInvincible_timeout():
	$RefreshAfterInvincible.stop();
	refreshAfterInvincible = false;
	pass


func _on_WallJumpNoTurnBack_timeout():
	$WallJumpNoTurnBack.stop();
	wallJumping = false;
	pass # Replace with function body.


func _on_ShootAnimationDuration_timeout():
	$ShootAnimationDuration.stop();
	isShooting = false;
	pass # Replace with function body.


func _on_WallSlideStick_timeout():
	$WallSlideStick.stop();
	pass
	
func getSpriteAnimation(): #for other nodes
	return $PlayerSprite.get_animation();
	pass


func _on_WallSlideParticleInterval_timeout():
	$WallSlideParticleInterval.stop();
	canSpawnWSParticle = true;
	pass

func _on_StompSpinTime_timeout():
	$StompSpinTime.stop();
	stompSpinning = false;
	if(!is_dead):
		stomping = true;
		maxYSpeed_multiplier = 1.3;
		motion.y = 800;
	pass
	
func doNetworking():
	Network.self_data.position = self.position;
	if(motion.x != 0 || motion.y != 0):
		rpc_unreliable("_set_position", global_transform.origin);
	
	if(!get_tree().is_network_server()):
		if(Network.clientConnected != 1):
			get_node(scene_path).setError(str("Disconnected from Server. " + Network.getClientCodeMsg()));
	
	if(Network.notifications.size() > 0):
		for note in Network.notifications:
			get_node(scene_path).printThroughChat(note);
		Network.notifications = []
	
	get_node(scene_path).refreshChatWindow();
	pass

remote func _set_position(pos):
	if(!is_local_player):
		global_transform.origin = pos
	pass
	
	
func networkConstructPressedButtons():
	var bool0 = false;
	var bool1 = false;
	var bool2 = false;
	var bool3 = false;
	var bool4 = false;
	var bool5 = false;
	var bool6 = false;
	var bool7 = false;
	var bool8 = false;
	if(Input.is_action_just_pressed(JUMP_BTN)):
		 bool0 = true;
	if(Input.is_action_just_pressed(RUN_BTN)):
		 bool1 = true;
	if(Input.is_action_just_pressed(SPIN_BTN)):
		 bool2 = true;
	if(Input.is_action_just_pressed(UP_BTN)):
		 bool3 = true;
	if(Input.is_action_just_pressed(DOWN_BTN)):
		 bool4 = true;
	if(Input.is_action_pressed(LEFT_BTN)):
		 bool5 = true;
	if(Input.is_action_pressed(RIGHT_BTN)):
		 bool6 = true;
	if(Input.is_action_just_pressed(SHOOT_BTN)):
		 bool7 = true;
	if(Input.is_action_just_pressed(PAUSE_BTN)):
		 bool8 = true;
	return [bool0, bool1, bool2, bool3, bool4, bool5, bool6, bool7, bool8];
	pass
	
remote func networkSetPressedButtons(bools):
	Input.action_release(JUMP_BTN);
	Input.action_release(RUN_BTN);
	Input.action_release(SPIN_BTN);
	Input.action_release(UP_BTN);
	Input.action_release(DOWN_BTN);
	Input.action_release(LEFT_BTN);
	Input.action_release(RIGHT_BTN);
	Input.action_release(SHOOT_BTN);
	Input.action_release(PAUSE_BTN);
	if(bools[0]):
		Input.action_press(JUMP_BTN)
	if(bools[1]):
		Input.action_press(RUN_BTN)
	if(bools[2]):
		Input.action_press(SPIN_BTN)
	if(bools[3]):
		Input.action_press(UP_BTN)
	if(bools[4]):
		Input.action_press(DOWN_BTN)
	if(bools[5]):
		Input.action_press(LEFT_BTN)
	if(bools[6]):
		Input.action_press(RIGHT_BTN)
	if(bools[7]):
		Input.action_press(SHOOT_BTN)
	if(bools[8]):
		Input.action_press(PAUSE_BTN)
	pass
