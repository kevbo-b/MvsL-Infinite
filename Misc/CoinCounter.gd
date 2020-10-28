extends Node2D
class_name CoinCounter

func set_count(count):
	$Sprite.region_rect.position.x = count * 7;
	$Sprite.region_rect.position.y = 0;
	
	if(count == Global.max_coins):
		$Sprite.region_rect.position.y = 7;
		
	if(position.y < Global.level_boundary_rect.position.y):
		position.y = position.y + 16;
	pass

func _on_ShowDuration_timeout():
	$ShowDuration.stop();
	queue_free();
	pass
