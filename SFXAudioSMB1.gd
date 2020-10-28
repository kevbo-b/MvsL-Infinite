extends AudioStreamPlayer
class_name PersistentAudioSMB1

func _ready():
	pass
	
var timeToKill = 1;

func playSFX(obj, sfx):
	stream = sfx;
	obj.add_child(self);
	play();
	$DeleteTimer.wait_time = timeToKill;
	$DeleteTimer.start();
	pass

func _on_DeleteTimer_timeout():
	$DeleteTimer.stop();
	queue_free();
	pass

func respawn(): #UNUSED, star calls it (so game doesnt freeze)
	pass
	
func setRespawnable(): #UNUSED, star calls it (so game doesnt freeze)
	pass
