extends SMBInteractiveBlocks
class_name QuestionBlock

var alwaysHit = false;
var time = 0;

func _ready():
	initialize();
	pass

func initialize():
	if(!initialized):
		sprite = $BlockArea/BlockSprite;
		$BlockArea/BlockSprite.region_rect.position.y = palette * 32;
		old_rect_x = $BlockArea/BlockSprite.region_rect.position.x;
		old_y = sprite.position.y;
		above_block_area = $HitAboveArea;
		area_2d = $BlockArea;
		save_area2d_default_collisions();
		initialized = true;
		if(alwaysHit):
			sprite.region_rect.position.x = 48;
			empty = true;
			hit = true;
	pass

func _process(delta):
	time = time + delta;
	if(hit):
		if(content != 0 && !instant_release):
			if(content == 1):
				if(hit_from_below):
					drop_content(block_hitter, true);
				else:
					drop_content(block_hitter, false);
				instant_release = true;
		sprite.position.y = sprite.position.y + sprite_motion.y;
		if(hit_from_below):
			sprite_motion.y += 1;
			if(sprite.position.y >= old_y):
				hit = false;
				sprite.position.y = old_y;
				if(empty && !instant_release):
					drop_content(block_hitter, true);
		else:
			sprite_motion.y -= 1;
			if(sprite.position.y <= old_y):
				hit = false;
				sprite.position.y = old_y;
				if(empty && !instant_release):
					drop_content(block_hitter, false);
	
	elif(!empty):
		if(time > (48.0 / 60.0)):
			time = 0;
			sprite.region_rect.position.x = old_rect_x;
		if(time <= (24.0 / 60.0)):
			sprite.region_rect.position.x = old_rect_x;
		elif(time > (32.0 / 60.0) && time <= (40.0 / 60.0)):
			sprite.region_rect.position.x = old_rect_x + 32;
		else:
			sprite.region_rect.position.x = old_rect_x + 16;

	pass
	
func hit_by_player(body, fromBelow = true):
	if(body == null):
		hit_by_enemy(null, null);
	else:
		initialize();
		block_hitter = body;
		if(!hit && !empty):
			kick_ontop_of_block(body, body);
			if(content == 0):
				if(body.item_state > 0):
					destroy_block();
				else:
					blockHitAnim(fromBelow);
			else:
				blockHitAnim(fromBelow);
				sprite.region_rect.position.x = 48;
				empty = true;
	pass
	
func hit_by_enemy(enemy, kicker_player):
	initialize();
	block_hitter = kicker_player;
	if(!empty && !hit):
		kick_ontop_of_block(enemy, kicker_player);
		old_y = sprite.position.y;
		sprite_motion.y = -4;
		hit = true;
		sprite.region_rect.position.x = 48;
		empty = true;
	pass
	
func blockHitAnim(fromBelow):
	hit = true;
	old_y = sprite.position.y;
	if(fromBelow):
		hit_from_below = true;
		sprite_motion.y = -4;
	else:
		hit_from_below = false;
		sprite_motion.y = 4;
	pass
	
func reset_visually():
	sprite.region_rect.position.x = old_rect_x;
	sprite.position.y = old_y;
	hit = false;
	time = 0;
	pass

func restore(): #so questionblock doesnt get out of sync
	show();
	set_all_collisions(true);
	instant_release = false;
	if(!alwaysHit):
		empty = false;
		reset_visually();
	despawned = false;
	pass
