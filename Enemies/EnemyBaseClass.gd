extends SMBObjectBaseClass
class_name EnemyBaseClass

export var palette = 0;
var enemySprite;

const SOUND_KICKED = preload("res://SFX/8bitSMB/smb_kick.wav");
const SOUND_BUMP = preload("res://SFX/8bitSMB/smb_bump.wav");
const DESPAWN_SMOKE = preload("res://Player/WallSlideParticle.tscn");

const COIN = preload("res://Misc/Coin.tscn");

var previous_spawning_pos = Vector2();

var hit_by_block = false;
var is_dead = false;

var direction = 1;

var isOnScreen = false;
var canRespawn = false;

var canPlaySFX = true;

var walkToPlayer = true;

func _ready():
	previous_spawning_pos = position;
	save_default_collisions();
	setPalette();
	pass
	
func squished(body): #overridden
	pass
	
func is_shot(body, shooter):
	if(body is Fireball):
		dropCoin();
	dead();
	pass
	
func dropCoin():
	var c = COIN.instance();
	c.droppedFromEnemy(position);
	get_parent().call_deferred("add_child",c);
	pass
	
func dead(): #overriden
	pass

func despawn():
	if(spawned_from_generator):
		queue_free();
	else:
		set_all_collisions(false);
		hide();
		motion.x = 0;
		motion.y = 0;
		despawned = true;
		enemy_fall = false;
		position = previous_spawning_pos;
		is_dead = true;
	pass
	
func setRespawnable():
	if(despawned):
		canRespawn = true;
	#respawn();
	pass
	
func setOutOfBounds():
	if(!is_dead):
		canRespawn = true;
	pass
	
func changeDirection(extraChecks = true): #overriden
	pass
	
func respawn():
	if(despawned && !spawned_from_generator):
		canRespawn = false;
		motion.x = 0;
		motion.y = 0;
		set_all_collisions(true);
		show();
		despawned = false;
		is_dead = false;
		reset_visually();
	pass

func spawnOnSight():
	despawn();
	canRespawn = true;
	isOnScreen = true;
	pass
	
func reset_visually(): #overridden
	pass
	
func inHitbox(player): #overridden
	print("This will not work. It shouldnt");
	pass
	
func get_class():
	return "EnemyBaseClass";
	pass
	
func setIsOnScreen(param, walkLeft):
	if(param):
		if(isOnScreen == false && canRespawn):
			respawn();
		isOnScreen = true;
		
		if(!walkToPlayer):
			walkLeft = !walkLeft;
		
		if(walkLeft):
			changeDirection(false);
	else:
		isOnScreen = false;
	pass
	
func checkIfInPlayerReach():
	if(despawned):
		checkForSpawnablePosition();
	else:
		checkForDespawnablePosition();
	pass
	
func checkForSpawnablePosition():
	var inDistance = false;
	var walkLeft = false;
	
	for playerPosition in getPlayerPositions():
		if(playerPosition != null):
			
			var reach = checkIfBoxInReach(position, playerPosition, SPAWN_DISTANCE);
			if(reach[0]):
				inDistance = true;
				walkLeft = reach[1];
				break;
		pass
	
	setIsOnScreen(inDistance, walkLeft);
	pass

func checkForDespawnablePosition():
	var inDistance = false;
	
	for playerPosition in getPlayerPositions():
		if(playerPosition != null):
			
			if(checkIfBoxInReach(position, playerPosition, SPAWN_DISTANCE + DESPAWN_DISTANCE_ADD)[0]):
				inDistance = true;
				break;

	if(!inDistance):
		if(!is_dead):
			canRespawn = true;
		despawn();
	pass
	
func playEnemySFX(sound, needsOnScreen = true):
	if(canPlaySFX && (!needsOnScreen || isOnScreen)):
		if(sound == SOUND_BUMP):
			playFromChannel(2, SOUND_BUMP);
			
			canPlaySFX = false;
			var t = Timer.new()
			t.set_wait_time(0.2)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			t.queue_free();	#what if parent node is gone in these 0.2s? Crash?
			
			canPlaySFX = true;
		else:
			playFromChannel(2, sound);
	pass
	
func determineKick(body):
	if(body.position.x > position.x):
		kick(false, body);
	else:
		kick(true, body);
	pass
	
func kick(direction, player):
	pass
	
func setPalette():
	pass
	
func setInfiniteYScrolled(downwards):
	if(downwards && is_dead):
		despawn();
	pass
	
func setGenSpawned():
	spawned_from_generator = true;
	pass
	
func checkIfSquished():
	if(is_on_wall() || is_on_ceiling()):
		checkIfInsideWall();
	pass
	
func squishedByWall():
	playEnemySFX(SOUND_KICKED);
	var smokeParticle = DESPAWN_SMOKE.instance();
	smokeParticle.position = position;
	smokeParticle.process_material.scale = 2;
	get_parent().get_parent().add_child(smokeParticle);
	dead();
	despawn();
	pass
