extends SMBInteractiveBlocks

export var breakable = false;

func _ready():
	initialize();
	pass

func initialize():
	if(!initialized):
		sprite = $BlockArea/BlockSprite;
		$BlockArea/BlockSprite.region_rect.position.y = palette * 32;
		area_2d = $BlockArea;
		save_area2d_default_collisions();
		initialized = true;
	pass

func destroy_block(player = null):
	if(breakable):
		spawn_block_breaks(player);
		set_all_collisions(false);
		hide();
		despawned = true;
	pass
	
func restore():
	if(despawned):
		show();
		set_all_collisions(true);
		empty = false;
		instant_release = false;
		reset_visually();
		despawned = false;
	pass

func stomped_on(player):
	player.stomping = false;
	pass
