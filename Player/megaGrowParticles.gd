extends Particles2D

#const OWN = preload("res://Player/StarSparkleParticle.tscn");
var player = 2;

func _ready():
	$Lifetime.wait_time = lifetime;
	emitting = true;
	$Lifetime.start();
	pass

func _on_Lifetime_timeout():
	$Lifetime.stop();
	queue_free();
	pass
