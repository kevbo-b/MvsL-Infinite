extends SMBInteractiveBlocks
class_name InvisibleBlock

const QUESTION_BLOCK = preload("res://Blocks/QuestionBlock.tscn");
var current_block;
export var completelyInvisible = false;

func _ready():
	initialize();
	pass # Replace with function body.

func initialize():
	if(!initialized):
		sprite = $AnimatedSprite;
		area_2d = $Area2D;
		above_block_area = $HitAboveArea;
		save_area2d_default_collisions();
		if(completelyInvisible):
			sprite.set_animation("invisible");
		initialized = true;
	pass

func hit_by_player(body, fromBelow = true):
	if(!hit):
		current_block = QUESTION_BLOCK.instance();
		current_block.content = self.content;
		current_block.palette = self.palette;
		current_block.position = self.position;
		current_block.hit_by_player(body);
		get_parent().call_deferred("add_child",current_block);
		
		hide();
		set_all_collisions(false);
		kick_ontop_of_block(body, body);
		hit = true;
		empty = true;
	pass
	
func destroy_block(player = null):
	if(hit):
		spawn_block_breaks(player);
		set_all_collisions(false);
		hide();
		despawned = true;
	pass
	
func reset_visually():
	if(current_block != null && hit == true):
		current_block.queue_free();
	hit = false;
	pass
	
func stomped_on(player):
	pass
