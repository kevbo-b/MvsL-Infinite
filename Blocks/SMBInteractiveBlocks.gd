extends StaticBody2D
class_name SMBInteractiveBlocks

const MASS_MULTIPLICATOR = 5;
const block_break = preload("res://Blocks/BlockDestroyed/BlockBreak.tscn");

export(int, "Empty","Coin","Mushroom/Fireflower (state dependend)","Mushroom","Fireflower","Mini Mushroom","Star","Throwing Hammer","Mega Mushroom") var content = 0;
export var palette = 0;
var block_hit = false;
var empty = false;

var saved_collision_layer;
var saved_collision_mask;
var area_2d_collision_layer;
var area_2d_collision_mask;

var area_2d;
var initialized = false;

var sprite_motion = Vector2()
var hit = false;
var old_y;
var old_rect_x;
var block_hitter;
var instant_release = false;

var sprite;
var above_block_area;

var despawned = false;

var hit_from_below = true;

func _ready():
	save_default_collisions();
	pass # Replace with function body.
	
func getInstanceByContentNumber(contentNumber, body):
	if(contentNumber == 1):
		return load("res://Misc/Coin.tscn").instance();
	elif(contentNumber == 2):
		if(body != null):
			if("player" in body.name):
				if(body.item_state < 1):
					return load("res://Items/shroom.tscn").instance();
				else:
					return load("res://Items/FireFlower.tscn").instance();
			else:
				return load("res://Items/shroom.tscn").instance();
		else:
			return load("res://Items/shroom.tscn").instance();
	elif(contentNumber == 3):
		return load("res://Items/shroom.tscn").instance();
	elif(contentNumber == 4):
		return load("res://Items/FireFlower.tscn").instance();
	elif(contentNumber == 5):
		return load("res://Items/MiniMushroom.tscn").instance();
	elif(contentNumber == 6):
		return load("res://Items/PowerStar.tscn").instance();
	elif(contentNumber == 7):
		return load("res://Items/HammerPowerup.tscn").instance();
	elif(contentNumber == 8):
		return load("res://Items/MegaMushroom.tscn").instance();
	else:
		return null;
	pass
	
func save_default_collisions():
	saved_collision_layer = get_collision_layer();
	saved_collision_mask = get_collision_mask();
	pass

func save_area2d_default_collisions():
	area_2d_collision_layer = area_2d.get_collision_layer();
	area_2d_collision_mask = area_2d.get_collision_mask();
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
	pass

func kick_ontop_of_block(blockHitterBody, hittingPlayer):
	var objects = above_block_area.get_overlapping_areas();
	
	for node in objects:
		if(node.get_parent() != blockHitterBody): #cant kick himself
			node.get_parent().got_hit_from_block(hittingPlayer);
	pass

func drop_content(body, upwards = true):
	var item = getInstanceByContentNumber(content,body);
	
	if(item != null):
		if(content == 1): #if coin
			jump_from_box(item, body, upwards);
		else:
			slide_out_item(item, upwards);
	pass
	
func jump_from_box(item, hitter, upwards):
	if(upwards):
		item.position = Vector2(position.x + 8, position.y + 8);
		item.motion.y = -45 * MASS_MULTIPLICATOR;
	else:
		item.position = Vector2(position.x + 8, position.y + 48);
		item.motion.y = 45 * MASS_MULTIPLICATOR;
	item.spawn_from_box(hitter, upwards);
	get_parent().get_parent().add_child(item);
	pass
	
func slide_out_item(item, upwards):
	if(content == 5 && !upwards): #mini
		item.position = Vector2(position.x + 8, position.y + 4);
	else:
		item.position = Vector2(position.x + 8, position.y + 8);
	get_parent().get_parent().add_child(item);
	item.spawn_from_block(upwards);
	pass

func destroy_block(player = null):
	if(!despawned):
		spawn_block_breaks(player);
		set_all_collisions(false);
		hide();
		despawned = true;
		checkFor3DBlocks();
	pass

func stomped_on(player):
	if(content == null):
		destroy_block();
	hit_by_player(player, false);
	pass
	
func spawn_block_breaks(player = null):
	
	var i = 1;
	
	while i <= 4:
		var breaks = block_break.instance();
		breaks.palette = self.palette;
		breaks.position = self.position;
		breaks.motion.y = breaks.BOUNCE_Y * MASS_MULTIPLICATOR;
		
		if(i % 2 == 0):
			breaks.position.x = breaks.position.x + 8;
			breaks.motion.x = breaks.SPEED_X * MASS_MULTIPLICATOR;
		else:
			breaks.motion.x = -1 * breaks.SPEED_X * MASS_MULTIPLICATOR;
		if(i >= 3):
			breaks.position.y = breaks.position.y + 8;
			breaks.motion.y = breaks.motion.y + breaks.BOUNCE_ADD * MASS_MULTIPLICATOR;
			
		if(player != null):
			if(player.isMega):
				breaks.motion.x = breaks.motion.x + player.motion.x;
			
		get_parent().get_parent().call_deferred("add_child", breaks);
		i = i + 1;

	pass
	
func restore():
	if(despawned || empty):
		show();
		set_all_collisions(true);
		empty = false;
		instant_release = false;
		reset_visually();
		despawned = false;
	pass
	
func reset_visually(): #is overridden
	pass
	
func hit_by_player(body, fromBelow = true): #is overridden
	pass
	
func hit_by_enemy(enemy, kicker): #is overridden
	pass
	
func changeAnim(animation):
	sprite.set_animation(animation);
	pass
	
func checkFor3DBlocks():
	if(Global.threeDMode):
		for path in Global.canvas3DPaths:
			get_node(path).deleteInteractiveBlock((position.x / 16),(position.y / 16));
	pass
	
func get_class():
	return "SMBInteractiveBlocks";
	pass
