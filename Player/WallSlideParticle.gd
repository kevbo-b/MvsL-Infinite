extends Particles2D

func _ready():
	emitting = true;
	$deleteTimer.start();
	pass

func _on_deleteTimer_timeout():
	$deleteTimer.stop();
	queue_free();
	pass

func setRespawnable(): #Never need. Just when BigStar might call it, so theres no crash
	pass
