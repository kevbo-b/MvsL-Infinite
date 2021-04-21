extends Particles2D

#const OWN = preload("res://Player/StarSparkleParticle.tscn");
var player = 2;

func _ready():
	$Lifetime.wait_time = lifetime;
	$Lifetime.start();
	$SpawnNew.start();
	pass

func _on_Lifetime_timeout():
	$Lifetime.stop();
	queue_free();
	pass


func _on_SpawnNew_timeout():
	$SpawnNew.stop();
	if(player.have_star == true):
		var f = duplicate();
		f.position = player.position;
		f.player = player;
		get_parent().add_child(f);
	pass # Replace with function body.
