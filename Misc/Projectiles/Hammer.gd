extends Projectile
class_name ThrowingHammer

var MAX_HAMMER_FALLING_SPEED = 70 * MASS_MULTIPLICATOR;
var shootMotion = Vector2(15, 65);

func _ready():
	if(direction == 1):
		$ThrowHammerSprite.flip_h = true;
	else:
		$ThrowHammerSprite.flip_h = false;
	pass # Replace with function body.
	
func adjustMotion():
	motion = Vector2(shooter.motion.x + MASS_MULTIPLICATOR * shootMotion.x * direction, MASS_MULTIPLICATOR * shootMotion.y * -1);
	pass
	
func _physics_process(delta):
	motion.y += GRAVITY;
	motion.y = min(motion.y, MAX_HAMMER_FALLING_SPEED);
	motion = move_and_slide(motion, DEFAULT_UP);
	
	check_if_out_of_bounds();
	pass

func _on_DespawnTimer_timeout():
	$DespawnTimer.stop();
	if(!exploded):
		despawn();
	pass

func _on_HammerArea2D_body_entered(body):
	if(body.get_class() == "Player"):
		if(shooter != body):
			if(!body.have_star && !body.isMega):
				body.got_shot(direction, true);
	else:
		body.is_shot(self, shooter);
	pass
	
func get_class():
	return "ThrowingHammer";
	pass
