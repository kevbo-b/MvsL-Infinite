extends KinematicBody2D
class_name SMBObjectBaseClass

var level_boundary_rect;

const SPAWN_DISTANCE = Vector2(256, 256);       #Mainly for enemies
const SOUND_DISTANCE = Vector2(256, 256);       #Mainly for Player Sounds
const DESPAWN_DISTANCE_ADD = Vector2(96, 96);

const MASS_MULTIPLICATOR = 5;
const GRAVITY = 13;
const MAXIMUM_FALLING_SPEED = 200 * MASS_MULTIPLICATOR;

const DEFAULT_UP = Vector2(0,-1);
var motion = Vector2();

var saved_collision_layer;
var saved_collision_mask;
var area_2d_collision_layer;
var area_2d_collision_mask;
var area_2d_set = false;
var area_2d;
var initialized = false;

var despawned = false;
var spawned_from_generator = false;

var infinite_x_scroll = false;
var infinite_y_scroll = false;

var enemy_fall = false;

func _ready():
	level_boundary_rect = Global.level_boundary_rect;
	infinite_x_scroll = Global.level_infinite_horizontal_scroll;
	infinite_y_scroll = Global.level_infinite_vertical_scroll;
	pass # Replace with function body.
	
func got_hit_from_block(player = null):
	motion.y = - 40 * MASS_MULTIPLICATOR;
	pass
	
func save_default_collisions():
	saved_collision_layer = get_collision_layer();
	saved_collision_mask = get_collision_mask();
	pass

func save_area2d_default_collisions(area_2d_obj):
	if(!area_2d_set):
		area_2d = area_2d_obj;
		area_2d_collision_layer = area_2d.get_collision_layer();
		area_2d_collision_mask = area_2d.get_collision_mask();
		area_2d_set = true;
	pass

func set_all_collisions(on):
	if(on == false):
		set_collision_layer(0);
		set_collision_mask(0);
		area_2d.set_collision_layer(0);
		area_2d.set_collision_mask(0);
	else:
		set_collision_layer(saved_collision_layer);
		set_collision_mask(saved_collision_mask);
		area_2d.set_collision_layer(area_2d_collision_layer);
		area_2d.set_collision_mask(area_2d_collision_mask);
		if("player" in name):
			if(self.isMega):
				area_2d.set_collision_mask(self.megaCollMask);
	pass
	
func setArea2DCollision(on):
	if(on == false):
		area_2d.set_collision_layer(0);
		area_2d.set_collision_mask(0);
	else:
		area_2d.set_collision_layer(area_2d_collision_layer);
		area_2d.set_collision_mask(area_2d_collision_mask);
	pass
	
func setKinematicCollision(on):
	if(on == false):
		set_collision_layer(0);
		set_collision_mask(0);
	else:
		set_collision_layer(saved_collision_layer);
		set_collision_mask(saved_collision_mask);
	pass

func check_if_out_of_bounds(infiniteY = false, allowAboveScreen = true):
	motion.y = min(motion.y, MAXIMUM_FALLING_SPEED); #never too fast falling objects
	if(position.y >= level_boundary_rect.end.y || position.y < level_boundary_rect.position.y):
		if(!infinite_y_scroll && !infiniteY && position.y >= level_boundary_rect.end.y): #without !infiniteY
			setOutOfBounds();
			despawn();
		elif(infinite_y_scroll || infiniteY):
			if(position.y < level_boundary_rect.position.y):
				position.y = position.y + level_boundary_rect.size.y;
				setInfiniteYScrolled(false);
			else:
				position.y = position.y - level_boundary_rect.size.y;
				setInfiniteYScrolled(true);
		else:
			if(!allowAboveScreen):
				setOutOfBounds();
				despawn();
	if(position.x > level_boundary_rect.end.x || position.x < level_boundary_rect.position.x):
		if(infinite_x_scroll):
			if(position.x < level_boundary_rect.position.x):
				position.x = position.x + level_boundary_rect.size.x;
			else:
				position.x = position.x - level_boundary_rect.size.x;
		else:
			setOutOfBounds();
			despawn();
	pass
	
func setOutOfBounds(): #For enemies
	pass
	
func checkIfInsideWall(warpOut = false):
	var tr = transform;
	if(test_move(tr,Vector2(0,-1)) && test_move(tr,Vector2(0,1)) && test_move(tr,Vector2(1,0)) && test_move(tr,Vector2(-1,0))):
		if(warpOut):
			position.x = position.x + 16;
			#position.y = position.y + 16;
			motion.x = 0;
			motion.y = 0;
		else:
			squishedByWall();
	pass
	
func squishedByWall(): #overriden
	despawn();
	pass
	
func refreshAreaInMaskBits(area, maskBits : Array):
	for bit in maskBits:
		area.set_collision_mask_bit(bit, false);
		pass

	var t = Timer.new()
	t.set_wait_time(0.02)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
	yield(t, "timeout")
	t.queue_free();	
	
	for bit in maskBits:
		area.set_collision_mask_bit(bit, true);
		pass
	pass
	
func refreshAreaInLayerBits(area, maskBits : Array):
	for bit in maskBits:
		area.set_collision_layer_bit(bit, false);
		pass

	var t = Timer.new()
	t.set_wait_time(0.02)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
	yield(t, "timeout")
	t.queue_free();	
	
	for bit in maskBits:
		area.set_collision_layer_bit(bit, true);
		pass
	pass
	
func isInPlayerRaycast(player, body, length = 1.2):
	#print(str(player.name) + ": " + str(player.position.y) + ", " + str(body.name) + ": " + str(body.position.y));
	if(player.position.y < body.position.y - length):
		return true;
	else:
		return false;
	pass
	
func playFromChannel(channel, sfx, db_add = 0, isGlobalSound = false):
	if(isGlobalSound || localPlayerNearby(position)):
		if(channel == -1):
			get_node(Global.sfxStar_path).playSound(sfx, db_add);
		elif(channel == 1):
			get_node(Global.sfxC1_path).playSound(sfx, db_add);
		elif(channel == 2):
			get_node(Global.sfxC2_path).playSound(sfx, db_add);
		elif(channel == 3):
			get_node(Global.sfxC3_path).playSound(sfx, db_add);
		elif(channel == 4):
			get_node(Global.sfxC4_path).playSound(sfx, db_add);
		else:
			get_node(Global.sfxC0_path).playSound(sfx, db_add);
		pass
	
func localPlayerNearby(pos):
	var playSound = false;
	for pl in Global.player_instances:
		if(pl.is_local_player && checkIfBoxInReach(pos, pl.position, SOUND_DISTANCE)[0]):
			return true;
	return false;
	pass


func checkIfBoxInReach(vecA, vecB, checkBoxSize, calculateInfiniteWorlds = true):
	
	var in_reach_x = false;
	var in_reach_y = false;
	var bLeftFromA = true;
	
	if(vecA.x - checkBoxSize.x < vecB.x && vecA.x + checkBoxSize.x > vecB.x): #if x vecA is in range
		in_reach_x = true;
		bLeftFromA = (vecB.x < vecA.x);
	elif(infinite_x_scroll && calculateInfiniteWorlds):
		if(vecB.x - checkBoxSize.x < level_boundary_rect.position.x):
			var reach_x = level_boundary_rect.size.x + (vecB.x - checkBoxSize.x);
			if(vecA.x > reach_x):
				in_reach_x = true
				bLeftFromA = false
		if(vecB.x + checkBoxSize.x > level_boundary_rect.end.x):
			var reach_x = (vecB.x + checkBoxSize.x) - level_boundary_rect.size.x;
			if(vecA.x < reach_x):
				in_reach_x = true
				bLeftFromA = true
				
	
			
	if(vecA.y - checkBoxSize.y < vecB.y && vecA.y + checkBoxSize.y > vecB.y): #if y vecA is in range
		in_reach_y = true;
	elif(infinite_y_scroll && calculateInfiniteWorlds):
		if(vecB.y - checkBoxSize.y < 0):
			var reach_y = level_boundary_rect.size.y + (vecB.y - checkBoxSize.y);
			if(vecA.y > reach_y):
				in_reach_y = true
		if(vecB.y + checkBoxSize.y > level_boundary_rect.end.y):
			var reach_y = (vecB.y + checkBoxSize.y) - level_boundary_rect.size.y;
			if(vecA.y < reach_y):
				in_reach_y = true

	if(in_reach_x && in_reach_y):
		return [true, bLeftFromA];
	else:
		return [false, bLeftFromA];
	pass
	
func getPlayerPositions():
	return Global.playerPositions;
	pass
	
func setCollisionMaskBits(obj, maskBits : Array, param = true):
	for bit in maskBits:
		obj.set_collision_mask_bit(bit, param);
	pass
	
func respawn(): #overriden
	pass

func despawn(): #overriden
	queue_free();
	pass
	
func setInfiniteYScrolled(downwards): #overidden
	pass
	
func dead(): #overriden
	pass

func get_class():
	return "SMBObjectBaseClass";
	pass
