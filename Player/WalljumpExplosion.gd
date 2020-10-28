extends AnimatedSprite

func _ready():
	deleteAfterAnimation();
	pass

func deleteAfterAnimation():
	play();
	yield(self,"animation_finished");
	queue_free();
	pass
