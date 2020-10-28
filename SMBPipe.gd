extends SMBObjectBaseClass
class_name SMBPipe

const PIPE_SHADER = preload("res://Shader/pipe.shader");
const DESTROY_SOUND = preload("res://SFX/NSMB/nsmb_pipeDestroy.wav");

export (int, \
	"Same as Tilemap Palette", \
	"Green (Normal)", \
	"Castle", \
	"Snow", \
	"Ice", \
	"Water (World 9)", \
	"Red", \
	"Blue", \
	"Yellow") var pipeColor = 0;

export var pipeTileLength = 2;

export var isEnterable = false;
export var spawnID = 0;

export var isFastPipe = false;
export var fastPipeWarpTileLength = 2;

export var destroyablePipe = true;

var isDestroyed = false;
var pipeShortened = false;
var spawn_position : Vector2;
var spawn_length : int;
var spawn_rotation : float;

var rotation_speed = 0.08;

var infiniteYScrollAmount = 0;

var alwaysCenterPipeEntrancing = false;
var maxEnterableState = 100;

var direction : Vector2;

func _ready():
	setPipeColorByNumber(pipeColor);
	if(!infinite_y_scroll):
		level_boundary_rect.size.y += 16 * 5;
	setToFittingRotation();
	spawn_length = pipeTileLength;
	spawn_rotation = rotation;
	save_default_collisions();
	save_area2d_default_collisions(null);
	spawn_position = position;
	if(!isEnterable):
		$StaticBody2D/EnterPipe/EnterCollision.call_deferred("set_disabled",true);
	if(pipeTileLength < 1):
		pipeTileLength = 1;
	setPipeLength();
	pass # Replace with function body.
	
func _physics_process(delta):
	if(isDestroyed && !despawned):
		motion.y += GRAVITY;
		move_and_slide(motion, DEFAULT_UP);
		check_if_out_of_bounds();
		if(motion.x < 0):
			rotation += rotation_speed;
		else:
			rotation -= rotation_speed;
	pass
	
func setToFittingRotation():
	setToFittingRotationFunc(2);
	pass
	
func setToFittingRotationFunc(space):
	var spacing = space;
	direction = Vector2(0, 1);
	if(rotation_degrees > 269 && rotation_degrees < 271):
		flipSprites();
		$StaticBody2D/EnterPipe.position.x = $StaticBody2D/EnterPipe.position.x - spacing;
		$StaticBody2D/EnterPipe.scale.x = 0.8;
		direction = Vector2(1, 0);
	elif(rotation_degrees > 89 && rotation_degrees < 91):
		$StaticBody2D/EnterPipe.position.x = $StaticBody2D/EnterPipe.position.x + spacing;
		$StaticBody2D/EnterPipe.scale.x = 0.8;
		direction = Vector2(-1, 0);
	elif(rotation_degrees > 179 && rotation_degrees < 181):
		direction = Vector2(0, -1);
		flipSprites();
		
	if(isFastPipe):
		$StaticBody2D/EnterPipe.scale.x = 0.8;
	pass
	
func flipSprites():
	$StaticBody2D/Top.flip_h = true;
	$StaticBody2D/Middle.flip_h = true;
	$StaticBody2D/Middle.flip_v = true;
	$StaticBody2D/Buttom.flip_h = true;
	pass
	
func setInfiniteYScrolled(downwards):
	if(infiniteYScrollAmount == 1 && downwards):
		despawn();
	else:
		if(downwards == true):
			infiniteYScrollAmount += 1;
	pass
	
func restore():
	if(despawned || pipeShortened):
		respawn();
	pass
	
func destroy_pipe(player):
	if(destroyablePipe):
		if(spawn_rotation == 0 && player.position.y < position.y - 8):
			shortenPipe(Vector2(0,1));
		elif(rotation_degrees > 179 && rotation_degrees < 181 && player.position.y > position.y + 80):
			shortenPipe(Vector2(0,-1));
		elif(rotation_degrees > 89 && rotation_degrees < 91 && player.position.x > position.x + 24):
			shortenPipe(Vector2(-1,0));
		elif(rotation_degrees > 269 && rotation_degrees < 271 && player.position.x < position.x - 24):
			shortenPipe(Vector2(1,0));
		else:
			playFromChannel(1, DESTROY_SOUND, 5);	
			var dir = 1;
			if(player.motion.x < 0):
				dir = -1;
			motion.x = 2 * 35 * MASS_MULTIPLICATOR * dir;
			setPipeDestroyed();
	pass
	
func shortenPipe(direction : Vector2):
	pipeShortened = true;
	
	position.y += 16 * direction.y;
	position.x += 16 * direction.x;
	
	pipeTileLength -= 1;
	
	if(pipeTileLength == 0):
		set_all_collisions(false);
		despawn();
	else:
		setPipeLength();
	pass

func despawn():
	$StaticBody2D.hide();
	despawned = true;
	motion.x = 0;
	motion.y = 0;
	pass
	
func respawn():
	infiniteYScrollAmount = 0;
	rotation = spawn_rotation;
	pipeTileLength = spawn_length;
	setPipeLength();
	$StaticBody2D/Buttom.hide();
	$StaticBody2D.show();
	despawned = false;
	pipeShortened = false;
	position = spawn_position;
	set_all_collisions(true);
	isDestroyed = false;
	pass

func setPipeLength():
	$StaticBody2D/PipeCollision.scale.y = pipeTileLength * 0.8;
	$StaticBody2D/PipeCollision.position.y = pipeTileLength * 16 / 2;
	
	$PipeDetectableArea.scale.y = pipeTileLength * 0.8;
	$PipeDetectableArea.position.y = pipeTileLength * 16 / 2;
	
	$StaticBody2D/Middle.region_rect.size.y = 16 * (pipeTileLength - 1);
	pass
	
func setPipeDestroyed():
	pipeShortened = false;
	if(pipeTileLength > 1):
		$StaticBody2D/Buttom.show();
		$StaticBody2D/Buttom.position.y = $StaticBody2D/Middle.region_rect.size.y;
		$StaticBody2D/Middle.region_rect.size.y -= 16;
	set_all_collisions(false);
	isDestroyed = true;
	pass

func save_default_collisions():
	saved_collision_layer = $StaticBody2D.get_collision_layer();
	saved_collision_mask = $StaticBody2D.get_collision_mask();
	pass

func save_area2d_default_collisions(area_2d_obj):
	area_2d_collision_layer = $StaticBody2D/EnterPipe.get_collision_layer();
	area_2d_collision_mask = $StaticBody2D/EnterPipe.get_collision_mask();
	pass
	
func set_all_collisions(on):
	if(on == false):
		$StaticBody2D.set_collision_layer(0);
		$StaticBody2D.set_collision_mask(0);
		$StaticBody2D/EnterPipe.set_collision_layer(0);
		$StaticBody2D/EnterPipe.set_collision_mask(0);
		if(isEnterable):
			$StaticBody2D/EnterPipe/EnterCollision.call_deferred("set_disabled", true);
		$PipeDetectableArea/DetectableArea.call_deferred("set_disabled", true);
	else:
		$StaticBody2D.set_collision_layer(saved_collision_layer);
		$StaticBody2D.set_collision_mask(saved_collision_mask);
		$StaticBody2D/EnterPipe.set_collision_layer(area_2d_collision_layer);
		$StaticBody2D/EnterPipe.set_collision_mask(area_2d_collision_mask);
		if(isEnterable):
			$StaticBody2D/EnterPipe/EnterCollision.call_deferred("set_disabled", false);
		$PipeDetectableArea/DetectableArea.call_deferred("set_disabled", false);
	pass
	
func getEnteringCenter():
	return getPipeTopCenter(32);
	pass
	
func getPipeTopCenter(width):
	var pipeWidth = width;
	var add = Vector2(0,0);
	
	if(rotation_degrees > 269 && rotation_degrees < 271):
		add.y = 0;
	elif(rotation_degrees > 89 && rotation_degrees < 91):
		add.y = pipeWidth;
	elif(rotation_degrees > 179 && rotation_degrees < 181):
		add.x = pipeWidth / -2;
	else:
		add.x = pipeWidth / 2;
	
	return Vector2(position.x + add.x, position.y + add.y);
	pass

func getWarpLengthInTiles():
	var difference = spawn_length - pipeTileLength;
	return fastPipeWarpTileLength - difference;
	pass

func setPipeColorByNumber(colNum):
	
	if(colNum == 0):
		colNum = Global.current_tileMap_palette;
	
	var color : Array;
	
	var col1 : Color;
	var col2 : Color;
	var col3 : Color;
	
	if(colNum == 2): #Castle
		col1 = Color(0.996, 1, 1, 1);
		col2 = Color(0.388, 0.388, 0.388, 1);
		col3 = Color(0.678, 0.678, 0.678, 1);
	elif(colNum == 3): #Snow
		col1 = Color(0.996, 1, 1, 1);
		col2 = Color(0.678, 0.678, 0.678, 1);
		col3 = Color(0.388, 0.388, 0.388, 1);
	elif(colNum == 4): #Ice
		col1 = Color(0.996, 1, 1, 1);
		col2 = Color(0.565, 0.878, 0.910, 1);
		col3 = Color(0.149, 0.482, 0.545, 1);
	elif(colNum == 5): #World 9
		col1 = Color(0.710, 0.129, 0.482, 1);
		col2 = Color(0.259, 0.259, 1, 1);
		col3 = Color(1, 0.420, 0.808, 1);
	if(colNum == 6): #Red
		col1 = Color(0.878, 0.620, 0.165, 1);
		col2 = Color(0.682, 0.184, 0.157, 1);
		col3 = Color(0.0, 0.0, 0.0, 1.0);
	elif(colNum == 7): #Blue
		col1 = Color(0, 0.580, 1, 1);
		col2 = Color(0.259, 0.259, 0.863, 1);
		col3 = Color(0, 0, 0, 1);
	elif(colNum == 8): #Yellow
		col1 = Color(0.980, 0.980, 0.502, 1);
		col2 = Color(0.902, 0.902, 0.235, 1);
		col3 = Color(0, 0, 0, 1);
		
	if(colNum > 1):
		setPipeColor(col1, col2, col3);
	pass
	
func setPipeColor(color1, color2, color3):
	var pipeMaterial = ShaderMaterial.new();
	pipeMaterial.shader = PIPE_SHADER;
	
	pipeMaterial.set_shader_param("newCol1", color1);
	pipeMaterial.set_shader_param("newCol2", color2);
	pipeMaterial.set_shader_param("newCol3", color3);
	
	$StaticBody2D.material = pipeMaterial;
	pass
