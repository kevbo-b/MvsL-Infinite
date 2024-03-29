extends SMBObjectBaseClass
class_name ItemBaseClass

const SPAWN_MOTION = -14;
const MAX_Y_SPEED = 64;
const DEFAULT_X_SPEED = 16; #will get multiplied with mass
const COINSPAWN_HEIGHT_FLAT_LEVEL = 72;
const COINSPAWN_HEIGHT_FLAT_LEVEL_FLAT_SCREEN = 104;
const COINSPAWN_HEIGHT = 64;
const COINSPAWN_Y_MARGIN = 16;

const SOUND_POWERUP_APPEARS = preload("res://SFX/8bitSMB/smb_powerup_appears.wav");
const IN_WALL_CHECKER = preload("res://Misc/InWallChecker.tscn");
const DESPAWN_SMOKE = preload("res://Player/WallSlideParticle.tscn");

const SOUND_KICKED = preload("res://SFX/8bitSMB/smb_kick.wav");

var direction = 1;
var player;
var spawning = false;
var time = 0;
var dropTimer;
var spawningIn = false;
var spawn_from_block = false;
var sprite;
var collected = false;
	
func toggle_sprite_on_off():
	if(sprite.visible):
		sprite.hide();
	else:
		sprite.show();
	pass
	
func spawn_as_drop(bodyy):
	initVariables();
	player = bodyy;
	spawning = true;
	motion.x = 0;
	motion.y = 0;
	set_all_collisions(false);
	direction = 0;
	spawningIn = true;
	#dropTimer.start();
	setPositionAbovePlayer();
	pass
	
func spawn_from_block(upwards = true):
	z_index = -2;
	
	playFromChannel(3, SOUND_POWERUP_APPEARS);
	
	initVariables();
	set_all_collisions(false);
	spawn_from_block = true;
	spawningIn = true;
	#dropTimer.start();
	if(upwards):
		motion.y = SPAWN_MOTION;
	else:
		motion.y = SPAWN_MOTION * -1;
	pass
	
func initVariables(): #overriden
	pass

func _on_Area2D_body_entered(body):
	if "player" in body.name:
		if(collected == false):
			collected = true;
			body.item_collected(self);
			queue_free();
	pass

func _on_DropSpawnTimer_timeout():
	if(spawningIn):
		dropTimer.stop();
		z_index = 1;
		if(spawn_from_block == true):
			set_all_collisions(true);
			spawn_from_block = false;
		else:
			spawning = false;
			sprite.show();
			setArea2DCollision(true);
			initWallCheckerUse();
	pass
	
func squishedByWall(): #overriden
	playFromChannel(0, SOUND_KICKED);
	var smokeParticle = DESPAWN_SMOKE.instance();
	smokeParticle.position = position;
	smokeParticle.process_material.scale = 2;
	get_parent().add_child(smokeParticle);
	queue_free();
	pass
	
func initWallCheckerUse():
	useWallChecker(-4, 10, true, 8.1);
	pass
	
func checkIfSquished():
	if(is_on_wall() || is_on_ceiling()):
		checkIfInsideWall();
	pass
	
func useWallChecker(yPosMovement, scanLength, useDoubleChecker, doubleCheckerSpacing = 8.1):
	var checker = IN_WALL_CHECKER.instance();
	checker.position.y = yPosMovement;
	if(useDoubleChecker):
		checker.setDoubleChecker(doubleCheckerSpacing);
	checker.setScanLength(scanLength);
	call_deferred("add_child",checker);
	pass
	
func calcMotionAndPosition():
	if(!spawning):
		if(!spawn_from_block):
			calcMotion();
	else:
		setPositionAbovePlayer();
	pass
	
func calcMotion(): #mostly overridden
	motion.x = DEFAULT_X_SPEED * MASS_MULTIPLICATOR * direction;
	motion.y += GRAVITY;
	motion.y = min(motion.y, MAX_Y_SPEED * MASS_MULTIPLICATOR);
	pass
	
func setPositionAbovePlayer():
	position.x = player.position.x;
	
	if(Global.level_infinite_vertical_scroll):
		position.y = player.position.y - COINSPAWN_HEIGHT;
		if(position.y < Global.level_boundary_rect.position.y):
			position.y = position.y + Global.level_boundary_rect.size.y;
	elif(Global.level_boundary_rect.size.y > 256):
		position.y = max(player.position.y - COINSPAWN_HEIGHT, Global.level_boundary_rect.position.y + COINSPAWN_Y_MARGIN);
	else:
		if(!Global.player2LeftRight && Global.player_amount_local == 2):
			position.y = COINSPAWN_HEIGHT_FLAT_LEVEL_FLAT_SCREEN; # else players cant see item above them
		else:
			position.y = COINSPAWN_HEIGHT_FLAT_LEVEL;
	pass
