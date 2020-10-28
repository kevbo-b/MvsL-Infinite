extends Projectile
class_name Fireball

const SOUND_EXPLODE = preload("res://SFX/8bitSMB/smb_bump.wav");
const FIREBALL_SPEED = 64;
var explodeOnWall = false;

func _ready():
	if(direction == 1):
		$FireballArea2D/FireballSprite.flip_h = false;
	else:
		$FireballArea2D/FireballSprite.flip_h = true;
	pass

var x_pos_last_frame = null;
var y_pos_last_frame = null;

func _physics_process(delta):

	if(is_on_wall() && !exploded):
		explodeOnWall = true;
		explode()
	
	if(!exploded):
		motion.x = FIREBALL_SPEED * MASS_MULTIPLICATOR * direction
		motion.y += GRAVITY
		if is_on_floor():
			motion.y = -100

	motion = move_and_slide(motion, DEFAULT_UP);
	
	if(x_pos_last_frame == position.x && y_pos_last_frame == position.y):
		explode();
	
	x_pos_last_frame = position.x;
	y_pos_last_frame = position.y;
	
	check_if_out_of_bounds();
	
	if(($FireballArea2D/FireballSprite.get_frame() >= 2 && exploded)):
		queue_free();
	
	pass
	
func explode():
	if(!exploded):
		$FireballArea2D/FireballSprite.set_animation("explode")
		$FireballKinBodyShape.queue_free();
		$FireballArea2D/FireballArea2DShape.queue_free();
		shooter.projectilesActive = shooter.projectilesActive - 1;
		motion.x = 0;
		motion.y = 0;
		exploded = true;
		if(explodeOnWall):
			playFromChannel(0, SOUND_EXPLODE);
	pass

func _on_FireballArea2D_body_entered(body):
	if(body.get_class() == "Player"):
		if(shooter != body):
			explode();
			if(!body.have_star && !body.isMega):
				body.got_shot(direction);
	else:
		explode();
		body.is_shot(self, shooter);
	pass

func _on_DespawnTimer_timeout():
	$DespawnTimer.stop();
	if(!exploded):
		despawn();
	pass

func get_class():
	return "Fireball";
	pass
