extends Node2D
class_name InWallChecker

#Checks constantly if a object is inside a wall. 
#If the object gets outside a wall, it re-enables the objects collision and deletes itself.
var doubleChecker = false;

func _ready():
	if(!doubleChecker):
		$InWallCheckerRight.queue_free();
	pass # Replace with function body.

func _physics_process(delta):
	testIfFree();
	pass
	
func setScanLength(length):
	$InWallCheckerLeft.cast_to.y = length;
	if(doubleChecker):
		$InWallCheckerRight.cast_to.y = length;
	pass

func testIfFree():
	if(!$InWallCheckerLeft.is_colliding()):
		if(doubleChecker):
			if(!$InWallCheckerRight.is_colliding()):
				scanFinished();
		else:
			scanFinished();
	pass
	
func setDoubleChecker(spacing):
	doubleChecker = true;
	$InWallCheckerLeft.position.x = spacing / -2;
	$InWallCheckerRight.position.x = spacing / 2;
	$InWallCheckerLeft.cast_to.x = spacing;
	$InWallCheckerRight.cast_to.x = spacing * -1;
	pass
	
func scanFinished():
	get_parent().setKinematicCollision(true);
	queue_free();
	pass
