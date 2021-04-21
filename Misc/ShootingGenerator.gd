extends Position2D

const SHOOTING_SOUND = preload("res://SFX/8bitSMB/smb_fireworks.wav"); 
const GEN_SPAWN_DISTANCE = Vector2(256, 256);
const OBJ_BASE_CLASS = preload("res://Classes/SMBObjectBaseClass.gd");

export var is_enabled = true;
export var shooting_interval = 4.0;
export(int, "Bullet Bill","Red Koopa","Green Koopa","BuzzyBeetle") var content = 0;
var gen_fixed = true;
var contentNode;
var content_file;
var shootRight = false;

export var oneWayShootDirection = false;
export var motion_horizontally = 1.0;
export var motion_vertically = 0.0;

export var palette = 0;
export var play_sound = true;
export var only_shoot_once = false;

export var solidSpawnTile = true; #so the direction for shells is still right

func _ready():
	initiateContent();
	$ShootingInterval.wait_time = max(shooting_interval, 0.05);
	start_shooting();
	pass # Replace with function body.

func initiateContent():
	if(content == 0):
		content_file = load("res://Enemies/BulletBill.tscn");
	elif(content == 1):
		content_file = load("res://Enemies/KoopaRed.tscn");
	elif(content == 2):
		content_file = load("res://Enemies/KoopaGreen.tscn");
	elif(content == 3):
		content_file = load("res://Enemies/BuzzyBeetle.tscn");
	pass
	
func playerInReach():
	var val = false;
	var tempOBJ = OBJ_BASE_CLASS.new();
	tempOBJ._ready()
	for playerPosition in Global.playerPositions:
		if(playerPosition != null):
			val = tempOBJ.checkIfBoxInReach(position, playerPosition, GEN_SPAWN_DISTANCE);
			if(val[0]):
				shootRight = !val[1];
				if(!oneWayShootDirection && position.x + 16 > playerPosition.x && position.x - 16 < playerPosition.x):
					val[0] = false;
				else:
					break; #der spieler der am weitesten am shooter dran ist = shooting direction
	tempOBJ.queue_free();
	return val[0];
	pass

func start_shooting():
	if(is_enabled):
		contentNode = content_file.instance();
		if(content == 0):
			contentNode.motion_horizontally = motion_horizontally;
			contentNode.motion_vertically = motion_vertically;
		$ShootingInterval.start();
	pass

func _on_ShootingInterval_timeout():
	$ShootingInterval.stop();
	if(is_enabled && playerInReach()):
		contentNode.setGenSpawned();
		contentNode.isOnScreen = true;
		contentNode.palette = palette;
		if(shootRight && !oneWayShootDirection):
			contentNode.changeDirection(false);
		if(gen_fixed):
			contentNode.position = position;
			get_parent().get_node("Enemies").add_child(contentNode);
		else:
			contentNode.position = get_parent().position;
			get_parent().get_parent().get_node("Enemies").add_child(contentNode);
		check_if_shell();
		if(play_sound):
			contentNode.playFromChannel(1, SHOOTING_SOUND);
	start_shooting();
	if(only_shoot_once):
		is_enabled = false;
	pass

func check_if_shell():
	var n = contentNode.get_class();
	if(n == "KoopaGreen" || n == "KoopaRed" || n == "BuzzyBeetle"):
		if(!solidSpawnTile):
			contentNode.kick(shootRight, self);
		else:
			contentNode.kick(!shootRight, self);
		print(shootRight)
		if(shootRight):
			contentNode.position.x = position.x + 8;
		else:
			contentNode.position.x = position.x - 8;
	pass
