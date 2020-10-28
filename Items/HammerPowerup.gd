extends FireFlower
class_name HammerPowerup

func initVariables():
	if(!initialized):
		save_default_collisions();
		save_area2d_default_collisions($Area2D);
		sprite = $Area2D/HammerSprite;
		dropTimer = $DropSpawnTimer;
		initialized = true;
	pass

func get_class():
	return "HammerPowerup";
	pass
