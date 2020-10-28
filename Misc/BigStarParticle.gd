extends Particles2D

func _ready():
	$Lifetime.wait_time = lifetime;
	$Lifetime.start();
	pass

func _on_Lifetime_timeout():
	queue_free();
	pass
