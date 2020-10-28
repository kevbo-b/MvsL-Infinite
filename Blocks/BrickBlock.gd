extends SMBInteractiveBlocks
class_name BrickBlock

export var lostLevelsStyle = false;
export var inner_block = false;

func _ready():
	initialize();
	pass
	
func initialize():
	if(!initialized):
		sprite = $BlockArea/BlockSprite;
		init_region_rect();
		above_block_area = $HitAboveArea;
		area_2d = $BlockArea;
		save_area2d_default_collisions();
		initialized = true;
	pass
	
func init_region_rect():
	old_y = sprite.position.y;
	if(lostLevelsStyle):
		sprite.region_rect.position.x = 272;
	if(inner_block):
		sprite.region_rect.position.x = sprite.region_rect.position.x + 16;
	old_rect_x = $BlockArea/BlockSprite.region_rect.position.x;
	$BlockArea/BlockSprite.region_rect.position.y = palette * 32;
	pass

func _process(delta):
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
				old_rect_x = sprite.region_rect.position.x;
				sprite.region_rect.position.x = 48;
				empty = true;
	pass
	
func hit_by_enemy(enemy, kicker_player):
	initialize();
	block_hitter = kicker_player;
	if(content == 0):
		kick_ontop_of_block(enemy, kicker_player);
		destroy_block();
	elif(!empty && !hit):
		kick_ontop_of_block(enemy, kicker_player);
		blockHitAnim(true);
		old_rect_x = sprite.region_rect.position.x;
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
	pass
