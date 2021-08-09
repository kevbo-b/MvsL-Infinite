extends SMBObjectBaseClass
class_name PawBlock

const POW_PARTICLE = preload("res://Misc/PowParticle.tscn");
const SOUND_POW = preload("res://SFX/8bitSMB/mb_Pow.wav");

export(int, "Blue","Red","Green","Yellow","Violette","Brown") var typeAsColor = 0;
export var falling = false;
export var trigger_other_pows = true;
export var kill_triggering_enemy = true;

var explodeIncrement = 0.4; #speed
var maxExplodeRadius = 6;

var old_position;

var hitPlayer = null;
var hitEnemy = null;

var hit = false;

func _ready():
	initialize();
	pass
	
func initialize():
	if(!initialized):
		$PawSprite.region_rect.position.y = 16 * typeAsColor;
		if(typeAsColor == 2 || typeAsColor == 4 || typeAsColor == 5):
			maxExplodeRadius = 12;
		if(typeAsColor == 3):
			explodeIncrement = 0.1;
		save_area2d_default_collisions($PawBlockDetectionArea);
		save_default_collisions();
		old_position = position;
		initialized = true;
		setHitShader(false);
	pass
	
func _physics_process(delta):
	if(falling && !hit):
		motion.y += GRAVITY;
		motion = move_and_slide(motion,DEFAULT_UP);
	
	if(hit && !despawned):
		$BlastRadius.scale = Vector2($BlastRadius.scale.x + explodeIncrement, $BlastRadius.scale.y + explodeIncrement);
		if($BlastRadius.scale.x > maxExplodeRadius):
			despawn();
	pass
	
func hit_by_player(player):
	if(!hit):
		explode(player);
	pass
	
func hit_by_enemy(enemy, kicker_player):
	if(!hit):
		if(!enemy.is_dead && kill_triggering_enemy):
			enemy.dead();
		hitEnemy = enemy;
		explode(kicker_player);
	pass
	
func despawn():
	if(!despawned):
		setHitShader(false);
		setCollisionMaskBits($BlastRadius,[0, 1, 3], false);
		hide();
		despawned = true;
		set_all_collisions(false);
		#$BlastRadius.scale = Vector2(0.6,0.6);
		pass
	pass
	
func restore():
	if(despawned):
		$BlastRadius.scale = Vector2(0.6,0.6);
		despawned = false;
		position = old_position;
		hit = false;
		show();
		set_all_collisions(true);
		setCollisionMaskBits($BlastRadius,[0, 1, 3]);
	pass
	
func destroy_block(player = null):
	hit_by_player(player);
	pass
	
func explode(hitter): #only NULL if gen spawned
	if(!hit):
		set_all_collisions(false); #NOT the blast radius
		hitPlayer = hitter;
		$testTimer.start();
		
		var particle = POW_PARTICLE.instance();
		if(typeAsColor == 3):
			particle.process_material.initial_velocity = 67;
		else:
			particle.process_material.initial_velocity = 250;
		add_child(particle);
		setHitShader(true);
		
		playFromChannel(0, SOUND_POW);
	pass
	
func setHitShader(param):
	var powShader;
	var powMaterial = ShaderMaterial.new();
	
	if(param):
		powShader = load("res://Shader/PowActivatedShader.shader");

	powMaterial.shader = powShader;
	$PawSprite.material = powMaterial;
	pass

func _on_BlastRadius_area_shape_entered(area_id, area, area_shape, self_shape):
	if("Block" in area.name && area.get_parent() != self):
		if(!(("Paw" in area.name) || ("Pow" in area.name))):
			if(typeAsColor == 1 || typeAsColor == 4 || typeAsColor == 5):
				if(area.get_parent().content != 0 && typeAsColor == 5):
					if(hitPlayer == null):
						area.get_parent().hit_by_player(null);
					else:
						area.get_parent().hit_by_player(hitPlayer);
				elif(!("BreakableHardBlock" in area.get_parent().name) || !typeAsColor == 5):
					area.get_parent().destroy_block();
			elif(hitPlayer == null):
				area.get_parent().hit_by_player(null);
			else:
				area.get_parent().hit_by_player(hitPlayer);
		elif(trigger_other_pows): #Pow Triggers
			if(hitPlayer == null):
				area.get_parent().hit_by_player(null);
			else:
				area.get_parent().hit_by_player(hitPlayer);
	elif("enemie" in area.name && typeAsColor != 5 && hit):
		if(area.get_parent().is_dead == false):
			area.get_parent().dead();
	elif("player" in area.name && area.get_parent() != hitPlayer && typeAsColor != 5):
	#	if(!area.get_parent().have_star && area.get_parent().isMega && area.get_parent().invincible):
			if(typeAsColor == 1 || typeAsColor == 4):
				area.get_parent().damaged(self);
			else:
				area.get_parent().got_hit_from_block();
	pass
	
func get_class():
	return "SMBInteractiveBlocks";
	pass

func _on_testTimer_timeout():
	$testTimer.stop();
	hit = true;
	$BlastRadius/BlastCollision.disabled = false;
	pass # Replace with function body.
