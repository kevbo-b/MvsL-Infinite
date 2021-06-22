extends EnemyBaseClass
class_name JumpingFireball

var bounce = -100;
var idle = false;

func _ready():
	save_area2d_default_collisions($enemie_hitbox);
	spawnOnSight();
	pass # Replace with function body.

func _physics_process(delta):
	if(!idle):
		if(motion.y > 0):
			$FireballSprite.flip_v = true;
		else:
			$FireballSprite.flip_v = false;
		motion.y += GRAVITY;	
		motion = move_and_slide(motion, DEFAULT_UP);	
		check_if_out_of_bounds();
	pass

func check_if_out_of_bounds(infiniteY = false, allowAboveScreen = true):
	motion.y = min(motion.y, MAXIMUM_FALLING_SPEED); #never too fast falling objects
	if(position.y >= level_boundary_rect.end.y):
		idle = true;
		motion.y = 0;
		set_all_collisions(false);
		hide();
		$IdleTimer.start();
	pass

func _on_IdleTimer_timeout():
	$IdleTimer.stop();
	set_all_collisions(true);
	show();
	bounce = sqrt(2 * GRAVITY * (level_boundary_rect.size.y - previous_spawning_pos.y));
	motion.y = (-1) * bounce * MASS_MULTIPLICATOR;
	idle = false;
	pass # Replace with function body.

func _on_enemie_hitbox_body_entered(body):
	if(body != self):
		if(body.get_class() == "Player"):
			if(body.isMega || body.have_star):
				self.dead();
			else:
				body.damaged(self);
	pass # Replace with function body.
