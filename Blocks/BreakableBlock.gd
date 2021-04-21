extends SMBInteractiveBlocks
class_name BreakableHardBlock

func _ready():
	initialize();
	init_region_rect();
	pass # Replace with function body.

func initialize():
	if(!initialized):
		sprite = $BlockArea/BlockSprite;
		init_region_rect();
		area_2d = $BlockArea;
		save_area2d_default_collisions();
		initialized = true;
	pass
	
func init_region_rect():
	$BlockArea/BlockSprite.region_rect.position.y = palette * 32 + 16;
	pass
	
func stomped_on(player):
	if(!player.isMega):
		player.stomping = false;
	pass
