extends SMBObjectBaseClass
class_name CannonShooter

const GENERATOR = preload("res://Misc/ShootingGenerator.tscn");
export(String, FILE, "*.tscn") var content_file;
export var shooting_interval = 4;
var content;

func _ready():
	var gen = GENERATOR.instance();
	gen.content_file = content_file;
	gen.shooting_interval = shooting_interval;
	#gen.position = position;
	gen.gen_fixed = false;
	call_deferred("add_child", gen);
	pass # Replace with function body.
	
func _physics_process(delta):
	motion.y += GRAVITY;
	motion = move_and_slide(motion, DEFAULT_UP);
	check_if_out_of_bounds();
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
