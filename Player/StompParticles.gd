extends Particles2D

func _ready():
	$Lifetime.wait_time = lifetime - preprocess - 0.1;
	$Lifetime.start();
	pass

func _on_Lifetime_timeout():
	$Lifetime.stop();
	queue_free();
	pass
