extends SMBObjectBaseClass
class_name Projectile

var exploded = false;
var direction = 1;
var shooter;

func initializeShot(shootingPlayer, spawnPosition):
	shooter = shootingPlayer;
	adjustPosition(spawnPosition);
	adjustMotion();
	pass
	
func adjustPosition(pos):
	position = pos;
	if(shooter.get_looking_direction() == -1):
		position.x -= 25;
		setDirectionRight(false);
	pass
	
func adjustMotion(): #overriden
	pass
	
func setDirectionRight(dir):
	if(dir):
		direction = 1;
	else:
		direction = -1;
	pass
	
func despawn():
	shooter.projectilesActive -= 1;
	queue_free();
	pass
