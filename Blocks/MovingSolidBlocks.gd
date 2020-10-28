extends KinematicBody2D

const BLOCK_SIZE = 16;
const DEFAULT_UP = Vector2(0,-1);

var motion = Vector2();

var t = 0;

export var verticalAmplitudeInBlocks = 0;
export var horizontalAmplitudeInBlocks = 0;
export var timeMultiplier = 1.0;

var childs = [];

var cycle = 0;

func _ready():
	cycle = 2*PI/timeMultiplier;
	saveChildren();
	pass # Replace with function body.

func _physics_process(delta):
	motion.y = (sin(timeMultiplier * t) * (BLOCK_SIZE / 2) * verticalAmplitudeInBlocks) * timeMultiplier;
	motion.x = (sin(timeMultiplier * t) * (BLOCK_SIZE / 2) * horizontalAmplitudeInBlocks) * timeMultiplier;
	motion = move_and_slide(motion, DEFAULT_UP);
	
	t+= delta;
	
	if(t > cycle):
		t-= cycle;
		
	setChildrenMovingSpeed();
	pass
	
func setChildrenMovingSpeed():
	for child in childs:
		child.constant_linear_velocity = Vector2(abs(motion.x),abs(motion.y));
	pass

func saveChildren():
	for child in get_children():
		if(child is StaticBody2D):
			childs.append(child);
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
