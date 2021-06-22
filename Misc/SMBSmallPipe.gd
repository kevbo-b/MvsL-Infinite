extends SMBPipe

func _ready():
	if((rotation_degrees > 89 && rotation_degrees < 91) || (rotation_degrees > 269 && rotation_degrees < 271)):
		maxEnterableState = 0;
	$StaticBody2D/EnterPipe.scale.x = 0.6;	
	alwaysCenterPipeEntrancing = true;
	pass # Replace with function body.

func getEnteringCenter():
	return getPipeTopCenter(16);
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
