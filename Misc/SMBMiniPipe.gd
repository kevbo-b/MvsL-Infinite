extends SMBPipe

func _ready():
	maxEnterableState = -1;
	$StaticBody2D/EnterPipe.scale.x = 0.2;
	alwaysCenterPipeEntrancing = true;
	pass # Replace with function body.

func setToFittingRotation():
	setToFittingRotationFunc(-1);
	pass

func getEnteringCenter():
	return getPipeTopCenter(8);
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
