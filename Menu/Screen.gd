extends Node

onready var viewport1 = $WholeScreen/UpperScreen/ViewPlayer1/Viewport1;
onready var viewport2 = $WholeScreen/UpperScreen/ViewPlayer2/Viewport2;
onready var viewport3 = $WholeScreen/LowerScreen/ViewPlayer3/Viewport3;
onready var viewport4 = $WholeScreen/LowerScreen/ViewPlayer4/Viewport4;

onready var viewPlayer1 = $WholeScreen/UpperScreen/ViewPlayer1
onready var viewPlayer2 = $WholeScreen/UpperScreen/ViewPlayer2
onready var viewPlayer3 = $WholeScreen/LowerScreen/ViewPlayer3
onready var viewPlayer4 = $WholeScreen/LowerScreen/ViewPlayer4

onready var cam_1 = $WholeScreen/UpperScreen/ViewPlayer1/Viewport1/SplitscreenCam1;
onready var cam_2 = $WholeScreen/UpperScreen/ViewPlayer2/Viewport2/SplitscreenCam2;
onready var cam_3 = $WholeScreen/LowerScreen/ViewPlayer3/Viewport3/SplitscreenCam3;
onready var cam_4 = $WholeScreen/LowerScreen/ViewPlayer4/Viewport4/SplitscreenCam4;

const PIXEL_SEPARATION = 4;


const PLAYER_INSTANCE = preload("res://Player/player.tscn");

const CANVAS_3D_PACK = preload("res://Misc/3DCanvasPack.tscn");

var cams;

var infinite_horizontal = false;
var infinite_vertical = false;

var WORLD = load(Global.world_to_load);
var level;
var player_number;
var players;

var errStatus = 0;

var cam_scale_factor = 3;
var new_resolution = Vector2(1820, 1024);
var background;
const hud = preload("res://Player/HUD.tscn");
const win_screen = preload("res://Menu/WinScreen.tscn");
var game_won = false;
const pause_screen = preload("res://Menu/PauseScreen.tscn");
var pause;
var dimension = -1;

func _ready():
	get_tree().get_root().set_size_override(true, new_resolution);
	level = WORLD.instance();
	setSoundChannels();
	cams = [cam_1, cam_2, cam_3, cam_4];
	infinite_horizontal = Global.level_infinite_horizontal_scroll;
	infinite_vertical = Global.level_infinite_vertical_scroll;
	pause = pause_screen.instance();
	call_deferred("add_child", pause);
	fit_to_player_count();
	pass

func fit_to_player_count():

	addMissingNodes();
	
	players = Global.player_amount;
	set_map_limits();

	viewport1.call_deferred("add_child", level);
	
	call_deferred("set_screens_and_cams" ,players);
	
	if(Global.threeDMode):
		var untouchedTilemap = level.get_node("TileMap").duplicate();
		untouchedTilemap.setPalette(untouchedTilemap.palette);
		call_deferred("set3DMode", untouchedTilemap);
	
	viewport2.world_2d = viewport1.world_2d;
	viewport3.world_2d = viewport1.world_2d;
	viewport4.world_2d = viewport1.world_2d;
	
	if(level.has_node("LevelBackgrounds")):
		viewport2.call_deferred("add_child", level.get_node("LevelBackgrounds").duplicate());
		viewport3.call_deferred("add_child", level.get_node("LevelBackgrounds").duplicate());
		viewport4.call_deferred("add_child", level.get_node("LevelBackgrounds").duplicate());
	
	call_deferred("link_scene_to_player");
	call_deferred("link_huds");
	call_deferred("set_screen_separation");
	pass
	
func set_screens_and_cams(players):
	
	cam_1.target = level.get_node("player");
	level.get_node("player").cam_path = cam_1.get_path();

	if(players == 2 && !Global.player2LeftRight):
		cam_3.target = level.get_node("player2");
		level.get_node("player2").cam_path = cam_3.get_path();
	elif(players > 1):
		cam_2.target = level.get_node("player2");
		level.get_node("player2").cam_path = cam_2.get_path();
	
	if(players > 2):	
		cam_3.target = level.get_node("player3");
		level.get_node("player3").cam_path = cam_3.get_path();
		if(players > 3):
			cam_4.target = level.get_node("player4");
			level.get_node("player4").cam_path = cam_4.get_path();

	if(players == 1): #if online mode? But online mode may also have 2 player splitscreen...
		$WholeScreen/LowerScreen.queue_free();
		$WholeScreen/UpperScreen/ViewPlayer2.queue_free();
		cams = [cam_1];
		cam_scale_factor = 4;
	elif(players == 2): #Players now delete themselves
		if(Global.player2LeftRight):
			cams = [cam_1, cam_2];
			cam_scale_factor = 4;
			$WholeScreen/LowerScreen.queue_free();
		else:
			cams = [cam_1, cam_2];
			cam_scale_factor = 4;
			$WholeScreen/UpperScreen/ViewPlayer2.queue_free();
			$WholeScreen/LowerScreen/ViewPlayer4.queue_free();
	elif(players == 3):
		if(Global.player3BigScreen):
			$WholeScreen/LowerScreen/ViewPlayer4.queue_free();
		else:
			$WholeScreen/LowerScreen/ViewPlayer4/Viewport4/SplitscreenCam4.queue_free();
			#$WholeScreen/LowerScreen/ViewPlayer4/Viewport4.queue_free();
			#$WholeScreen/LowerScreen/ViewPlayer4.print_tree_pretty();
		cams = [cam_1, cam_2, cam_3];
		
	cam_1.zoom.x = cam_1.zoom.x / cam_scale_factor;
	cam_1.zoom.y = cam_1.zoom.y / cam_scale_factor;
	cam_2.zoom.x = cam_2.zoom.x / cam_scale_factor;
	cam_2.zoom.y = cam_2.zoom.y / cam_scale_factor;
	cam_3.zoom.x = cam_3.zoom.x / cam_scale_factor;
	cam_3.zoom.y = cam_3.zoom.y / cam_scale_factor;
	cam_4.zoom.x = cam_4.zoom.x / cam_scale_factor;
	cam_4.zoom.y = cam_4.zoom.y / cam_scale_factor;
	pass
	
func initialSpawnAllPlayers():
		
	var spacing = 48;
	if(!Global.is_vs_mode):
		spacing = 20;
	
	var startingPos = Vector2(40,216); #default	
	
	var spawns;	
	var differentSpawns = false;
	
	if(!level.has_node("SPAWNS")):
		setError("No spawn entities found in this Level.", 2);
	else:
		spawns = level.get_node("SPAWNS");
		var spawn = spawns.getSpawnByID(0);
		if(spawn != null):
			startingPos = spawn.position;
			differentSpawns = spawn.differentSpawnForPlayers;
		else:
			setError("No initial spawn found in this Level.", 2)

	
	for i in range(1, Global.player_amount + 1):
		if(!level.has_node("player" + str(i)) && i != 1 || !level.has_node("player") && i == 1):
			var player = PLAYER_INSTANCE.instance();
			if(differentSpawns && spawns.getSpawnByID(i - 1) != null):
				player.position = spawns.getSpawnByID(i - 1).position;
			else:
				player.position = Vector2(startingPos.x + spacing * (i - 1),startingPos.y);
			if(i != 1):
				player.set_name("player" + str(i));
			else:
				player.set_name("player");
			level.call_deferred("add_child", player);
		else:
			if(i == 1):
				startingPos = level.get_node("player").position;
		pass
	pass

func addMissingNodes():

	initialSpawnAllPlayers();
	
	if(!level.has_node("Coins")):
		var node = Node2D.new();
		node.set_name("Coins");
		level.add_child(node);
		
	if(!level.has_node("Blocks")):
		var node = Node2D.new();
		node.set_name("Blocks");
		level.add_child(node);
		
	if(!level.has_node("Enemies")):
		var node = Node2D.new();
		node.set_name("Enemies");
		level.add_child(node);
	
	if(!level.has_node("BigStarPositions") && Global.is_vs_mode):
		var node = Node2D.new();
		node.set_name("BigStarPositions");
		level.add_child(node);

	pass
	
func link_scene_to_player():
	for i in range(1, Global.player_amount + 1):
		var player_str;
		if(i == 1):
			player_str = "player";
		else:
			player_str = "player" + str(i)
		level.get_node(player_str).scene_path = self.get_path();
	pass

func link_huds():
	viewPlayer1.call_deferred("add_child", hud.instance());
	level.get_node("player").hud_path = str(viewPlayer1.get_path()) + "/HUD";
	
	if(players == 2 && !Global.player2LeftRight):
		viewPlayer3.call_deferred("add_child", hud.instance());
		level.get_node("player2").hud_path = str(viewPlayer3.get_path()) + "/HUD";
	elif(players > 1):
		viewPlayer2.call_deferred("add_child", hud.instance());
		level.get_node("player2").hud_path = str(viewPlayer2.get_path()) + "/HUD";
		
	if(players > 2):
		viewPlayer3.call_deferred("add_child", hud.instance());
		level.get_node("player3").hud_path = str(viewPlayer3.get_path()) + "/HUD";
		if(players > 3):
			viewPlayer4.call_deferred("add_child", hud.instance());
			level.get_node("player4").hud_path = str(viewPlayer4.get_path()) + "/HUD";

	pass
	
func set_infinity_world():
	var bgWithColorOnly; #CutOffs when bg images avaiable, so setting bgimages off here
	var copyBG = false; #feature off, because it looks horrible in comparsion!
	
	if(copyBG && level.has_node("LevelBackgrounds")):
		bgWithColorOnly = level.get_node("LevelBackgrounds").duplicate();
		for bg in bgWithColorOnly.get_children():
			bg.useBackground = false;
			
	var undefinedLength = Vector2(256,256);
	
	if(infinite_horizontal || infinite_vertical):
		if(infinite_horizontal):
			$HiddenViewports/viewportWorldHorizontal1.world_2d = viewport1.world_2d;
			$HiddenViewports/viewportWorldHorizontal2.world_2d = viewport1.world_2d;
			
			if(copyBG && level.has_node("LevelBackgrounds")):
				$HiddenViewports/viewportWorldHorizontal1.call_deferred("add_child", bgWithColorOnly.duplicate());
				$HiddenViewports/viewportWorldHorizontal2.call_deferred("add_child", bgWithColorOnly.duplicate());
				
			var canvLeft = Sprite.new();
			var canvRight = Sprite.new();
			canvLeft.centered = false;
			canvRight.centered = false;
			
			var texture1 = $HiddenViewports/viewportWorldHorizontal1.get_texture();
			$HiddenViewports/viewportWorldHorizontal1.size = Vector2(undefinedLength.x,Global.level_boundary_rect.size.y);
			$HiddenViewports/viewportWorldHorizontal1/worldCamera.offset = Vector2(Global.level_boundary_rect.position.x,Global.level_boundary_rect.position.y);
			canvRight.set_texture(texture1);
			canvRight.offset = Vector2(Global.level_boundary_rect.end.x,Global.level_boundary_rect.position.y);
			
			var texture2 = $HiddenViewports/viewportWorldHorizontal2.get_texture();
			$HiddenViewports/viewportWorldHorizontal2.size = Vector2(undefinedLength.x,Global.level_boundary_rect.size.y);
			$HiddenViewports/viewportWorldHorizontal2/worldCamera.offset = Vector2(Global.level_boundary_rect.end.x - $HiddenViewports/viewportWorldHorizontal2.size.x, Global.level_boundary_rect.position.y);
			canvLeft.set_texture(texture2);
			canvLeft.offset = Vector2(Global.level_boundary_rect.position.x - $HiddenViewports/viewportWorldHorizontal2.size.x, Global.level_boundary_rect.position.y);

			if(Global.level_boundary_rect.position.y > 0):
				var sizeY = max(Global.level_boundary_rect.size.y, undefinedLength.y);
				$HiddenViewports/viewportWorldHorizontal1.size = Vector2(undefinedLength.x,sizeY);
				$HiddenViewports/viewportWorldHorizontal1/worldCamera.offset = Vector2(Global.level_boundary_rect.position.x,0);
				canvRight.offset = Vector2(Global.level_boundary_rect.end.x,0);
				$HiddenViewports/viewportWorldHorizontal2.size = Vector2(undefinedLength.x,sizeY);
				$HiddenViewports/viewportWorldHorizontal2/worldCamera.offset = Vector2(Global.level_boundary_rect.end.x - $HiddenViewports/viewportWorldHorizontal2.size.x, 0);
				canvLeft.offset = Vector2(Global.level_boundary_rect.position.x - $HiddenViewports/viewportWorldHorizontal2.size.x, 0);
				canvLeft.offset = Vector2(Global.level_boundary_rect.position.x - $HiddenViewports/viewportWorldHorizontal2.size.x, 0);

			var n2d = Node2D.new();
			n2d.set_name("InfinteHorizontalWorlds");
			n2d.add_child(canvLeft);
			n2d.add_child(canvRight);
			level.add_child(n2d);
		
		else:
			$HiddenViewports/viewportWorldHorizontal1.queue_free();
			$HiddenViewports/viewportWorldHorizontal2.queue_free();
			
		if(infinite_vertical):
			$HiddenViewports/viewportWorldVertical1.world_2d = viewport1.world_2d;
			$HiddenViewports/viewportWorldVertical2.world_2d = viewport1.world_2d;
			
			if(copyBG && level.has_node("LevelBackgrounds")):
				$HiddenViewports/viewportWorldVertical1.call_deferred("add_child", bgWithColorOnly.duplicate());
				$HiddenViewports/viewportWorldVertical2.call_deferred("add_child", bgWithColorOnly.duplicate());
			
			var canvTop = Sprite.new();
			var canvButtom = Sprite.new();
			canvTop.centered = false;
			canvButtom.centered = false;

			var textureTop = $HiddenViewports/viewportWorldVertical1.get_texture();
			$HiddenViewports/viewportWorldVertical1.size = Vector2(Global.level_boundary_rect.size.x,undefinedLength.y);
			$HiddenViewports/viewportWorldVertical1/worldCamera.offset = Vector2(Global.level_boundary_rect.position.x,Global.level_boundary_rect.end.y - $HiddenViewports/viewportWorldVertical1.size.y);
			canvTop.set_texture(textureTop);
			canvTop.offset = Vector2(Global.level_boundary_rect.position.x,Global.level_boundary_rect.position.y - $HiddenViewports/viewportWorldVertical1.size.y);
			
			var textureButtom = $HiddenViewports/viewportWorldVertical2.get_texture();
			$HiddenViewports/viewportWorldVertical2.size = Vector2(Global.level_boundary_rect.size.x,undefinedLength.y);
			$HiddenViewports/viewportWorldVertical2/worldCamera.offset = Vector2(Global.level_boundary_rect.position.x,Global.level_boundary_rect.position.y);
			canvButtom.set_texture(textureButtom);
			canvButtom.offset = Vector2(Global.level_boundary_rect.position.x,Global.level_boundary_rect.end.y);
			
			var n2d = Node2D.new();
			n2d.set_name("InfinteVerticalWorlds");
			n2d.add_child(canvTop);
			n2d.add_child(canvButtom);
			level.add_child(n2d);
			
		else:
			$HiddenViewports/viewportWorldVertical1.queue_free();
			$HiddenViewports/viewportWorldVertical2.queue_free();
			
		if(infinite_horizontal && infinite_vertical):
			$HiddenViewports/viewportWorldDiagonal1.world_2d = viewport1.world_2d;
			$HiddenViewports/viewportWorldDiagonal2.world_2d = viewport1.world_2d;
			$HiddenViewports/viewportWorldDiagonal3.world_2d = viewport1.world_2d;
			$HiddenViewports/viewportWorldDiagonal4.world_2d = viewport1.world_2d;
			
			if(copyBG && level.has_node("LevelBackgrounds")):
				$HiddenViewports/viewportWorldDiagonal1.call_deferred("add_child", bgWithColorOnly.duplicate());
				$HiddenViewports/viewportWorldDiagonal2.call_deferred("add_child", bgWithColorOnly.duplicate());
				$HiddenViewports/viewportWorldDiagonal3.call_deferred("add_child", bgWithColorOnly.duplicate());
				$HiddenViewports/viewportWorldDiagonal4.call_deferred("add_child", bgWithColorOnly.duplicate());
				
			var canvTopLeft = Sprite.new();
			var canvTopRight = Sprite.new();
			var canvButtomLeft = Sprite.new();
			var canvButtomRight = Sprite.new();
			canvTopLeft.centered = false;
			canvTopRight.centered = false;
			canvButtomLeft.centered = false;
			canvButtomRight.centered = false;
			
			var textureTopLeft = $HiddenViewports/viewportWorldDiagonal1.get_texture();
			$HiddenViewports/viewportWorldDiagonal1.size = undefinedLength;
			$HiddenViewports/viewportWorldDiagonal1/worldCamera.offset = Vector2(Global.level_boundary_rect.end.x - undefinedLength.x, Global.level_boundary_rect.end.y - undefinedLength.y);
			canvTopLeft.set_texture(textureTopLeft);
			canvTopLeft.offset = Vector2(Global.level_boundary_rect.position.x - undefinedLength.x, Global.level_boundary_rect.position.y - undefinedLength.y);
			
			var textureTopRight = $HiddenViewports/viewportWorldDiagonal2.get_texture();
			$HiddenViewports/viewportWorldDiagonal2.size = undefinedLength;
			$HiddenViewports/viewportWorldDiagonal2/worldCamera.offset = Vector2(Global.level_boundary_rect.position.x, Global.level_boundary_rect.end.y - undefinedLength.y);
			canvTopRight.set_texture(textureTopRight);
			canvTopRight.offset = Vector2(Global.level_boundary_rect.end.x, Global.level_boundary_rect.position.y - undefinedLength.y);
			
			var textureButtomLeft = $HiddenViewports/viewportWorldDiagonal3.get_texture();
			$HiddenViewports/viewportWorldDiagonal3.size = undefinedLength;
			$HiddenViewports/viewportWorldDiagonal3/worldCamera.offset = Vector2(Global.level_boundary_rect.end.x - undefinedLength.x,Global.level_boundary_rect.position.y);
			canvButtomLeft.set_texture(textureButtomLeft);
			canvButtomLeft.offset = Vector2(Global.level_boundary_rect.position.x - undefinedLength.x, Global.level_boundary_rect.end.y);
			
			var textureButtomRight = $HiddenViewports/viewportWorldDiagonal4.get_texture();
			$HiddenViewports/viewportWorldDiagonal4.size = undefinedLength;
			$HiddenViewports/viewportWorldDiagonal4/worldCamera.offset = Vector2(Global.level_boundary_rect.position.x,Global.level_boundary_rect.position.y);
			canvButtomRight.set_texture(textureButtomRight);
			canvButtomRight.offset = Vector2(Global.level_boundary_rect.end.x, Global.level_boundary_rect.end.y);
			
			var n2d = Node2D.new();
			n2d.set_name("InfinteDiagonalWorlds");
			n2d.add_child(canvTopLeft);
			n2d.add_child(canvTopRight);
			n2d.add_child(canvButtomLeft);
			n2d.add_child(canvButtomRight)
			level.add_child(n2d);
		
		else:
			$HiddenViewports/viewportWorldDiagonal1.queue_free();
			$HiddenViewports/viewportWorldDiagonal2.queue_free();
			$HiddenViewports/viewportWorldDiagonal3.queue_free();
			$HiddenViewports/viewportWorldDiagonal4.queue_free();
	else:
		$HiddenViewports/viewportWorldHorizontal1.queue_free();
		$HiddenViewports/viewportWorldHorizontal2.queue_free();
		$HiddenViewports/viewportWorldVertical1.queue_free();
		$HiddenViewports/viewportWorldVertical2.queue_free();
		$HiddenViewports/viewportWorldDiagonal1.queue_free();
		$HiddenViewports/viewportWorldDiagonal2.queue_free();
		$HiddenViewports/viewportWorldDiagonal3.queue_free();
		$HiddenViewports/viewportWorldDiagonal4.queue_free();
	pass
	
func set3DMode(untouchedTilemap):
	Global.canvas3DPaths = [];
	var tm = untouchedTilemap;
	var masterNode = CANVAS_3D_PACK.instance();
	masterNode.set_name("3DCanvasPack");
	
	var layerAmount = 4;
	var depthSteps = 0.015;
	
	var l = -1;
	
	for i in range(layerAmount * -1,0):
		var Canvas = CanvasLayer.new();
		Canvas.set_name("3DCanvLayer");
		var new_tm = tm.duplicate();
		new_tm.set_collision_layer(0);
		new_tm.set_collision_mask(0);
		Canvas.add_child(new_tm);
		Canvas.layer = l;
		Canvas.follow_viewport_enable = true;
		Canvas.follow_viewport_scale = 1 - depthSteps * l * -1;
		l -= 1;
		masterNode.add_child(Canvas);
		pass
	
	level.add_child(masterNode);
	
	if(Global.playing_splitscreen && players > 1):
		viewport2.add_child(level.get_node("3DCanvasPack").duplicate());
		if(players > 2):
			viewport3.add_child(level.get_node("3DCanvasPack").duplicate());
			if(players > 3):
				viewport4.add_child(level.get_node("3DCanvasPack").duplicate());
				
	if(infinite_horizontal):
		$HiddenViewports/viewportWorldHorizontal1.add_child(level.get_node("3DCanvasPack").duplicate());
		$HiddenViewports/viewportWorldHorizontal2.add_child(level.get_node("3DCanvasPack").duplicate());
	if(infinite_vertical):
		$HiddenViewports/viewportWorldVertical1.add_child(level.get_node("3DCanvasPack").duplicate());
		$HiddenViewports/viewportWorldVertical2.add_child(level.get_node("3DCanvasPack").duplicate());
	if(infinite_horizontal && infinite_vertical):
		$HiddenViewports/viewportWorldDiagonal1.add_child(level.get_node("3DCanvasPack").duplicate());
		$HiddenViewports/viewportWorldDiagonal2.add_child(level.get_node("3DCanvasPack").duplicate());
		$HiddenViewports/viewportWorldDiagonal3.add_child(level.get_node("3DCanvasPack").duplicate());
		$HiddenViewports/viewportWorldDiagonal4.add_child(level.get_node("3DCanvasPack").duplicate());
	pass

func set_map_limits():
	var map_limits = level.get_node("TileMap").get_used_rect();
	var map_cellsize = level.get_node("TileMap").cell_size;
	
	var screen_height = ProjectSettings.get_setting("display/window/size/height"); #256
	
	Global.level_boundary_rect = Rect2(Vector2(map_limits.position.x * map_cellsize.x,map_limits.position.y * map_cellsize.y),Vector2(map_limits.size.x * map_cellsize.x,map_limits.size.y * map_cellsize.y));
	
	var blockSpacingPos = Global.world_spacing_position;
	var blockSpacingEnd = Global.world_spacing_end;

	Global.level_boundary_rect = Rect2(Vector2(map_limits.position.x * map_cellsize.x, map_limits.position.y * map_cellsize.y),Vector2(map_limits.size.x * map_cellsize.x, map_limits.size.y * map_cellsize.y));
	
	var spacingAddition = [blockSpacingPos.x * map_cellsize.x, blockSpacingPos.y * map_cellsize.y, blockSpacingEnd.x * map_cellsize.x ,blockSpacingEnd.y * map_cellsize.y];
	Global.level_boundary_rect = Global.level_boundary_rect.grow_individual(spacingAddition[0],spacingAddition[1],spacingAddition[2],spacingAddition[3]);
	
	set_infinity_world();
	
	if(!infinite_vertical):
		Global.level_boundary_rect = Global.level_boundary_rect.grow_individual(0, 0, 0, 1 * map_cellsize.y);
	
	for cam in cams:
		if(!infinite_horizontal):
			cam.limit_left = map_limits.position.x * map_cellsize.x - spacingAddition[0];
			cam.limit_right = map_limits.end.x * map_cellsize.x + spacingAddition[2];
		if(!infinite_vertical):
			cam.limit_bottom = map_limits.end.y * map_cellsize.y + spacingAddition[3];	
			cam.limit_top = map_limits.position.y * map_cellsize.y - spacingAddition[1];
			if(screen_height > (cam.limit_bottom - cam.limit_top)):
				cam.limit_top = cam.limit_bottom - screen_height;			
	pass
	
func set_screen_separation():
	if(players > 1):
		$WholeScreen/UpperScreen.add_constant_override("separation", PIXEL_SEPARATION);
		if(players > 2):
			$WholeScreen.add_constant_override("separation", PIXEL_SEPARATION);
			if(players > 3):
				$WholeScreen/LowerScreen.add_constant_override("separation", PIXEL_SEPARATION);
	pass
	
func toggle_pause(player):
	if(!game_won):
		pause.set_pause(player, self);
		#get_tree().paused = true;
	pass

func won_game(player):
	game_won = true;
	var win = win_screen.instance();
	win.set_winner(player, self);
	call_deferred("add_child", win);
	if(Global.inappropriate_mode):
		setFunWinScreen(player);
	get_tree().paused = true;
	pass
	
func setFunWinScreen(winner):
	
	if(winner.name != "player"):
		$WholeScreen/UpperScreen/ViewPlayer1/P1FunImage.texture = load("res://Levels/Textures/AnormalHunnel.jpg");
	elif(winner.name != "player2"):
		$WholeScreen/UpperScreen/ViewPlayer2/P2FunImage.texture = load("res://Levels/Textures/AnormalHunnel.jpg");
	elif(winner.name != "player3"):
		$WholeScreen/LowerScreen/ViewPlayer3/P3FunImage.texture = load("res://Levels/Textures/AnormalHunnel.jpg");
	elif(winner.name != "player4"):
		$WholeScreen/LowerScreen/ViewPlayer4/P4FunImage.texture = load("res://Levels/Textures/AnormalHunnel.jpg");
		
	pass
	
func setSoundChannels():
	#to access all Music Nodes Globally (From a Player for example)
	Global.musicC1_path = $MusicChannel1.get_path();
	Global.sfxStar_path = $SFXStarCollect.get_path();
	Global.sfxC0_path = $SFXChannel0.get_path();
	Global.sfxC1_path = $SFXChannel1.get_path();
	Global.sfxC2_path = $SFXChannel2.get_path();
	Global.sfxC3_path = $SFXChannel3.get_path();
	Global.sfxC4_path = $SFXChannel4.get_path();
	
	#Set the proper level Song (If no Settings node there -> Random VS Song)
	if(level.has_node("LevelSettings")):
		var songtrackFile = level.get_node("LevelSettings").getSongtrackFile();
		$MusicChannel1.setSongtrack(songtrackFile);
		level.get_node("LevelSettings").setScrollProperties();
	else:
		Global.level_infinite_horizontal_scroll = false;
		Global.level_infinite_vertical_scroll = false;
		Global.world_spacing_in_blocks = Vector2(0,0);
	pass
	
func setError(message, status):
	errStatus = status;
	$ErrorWindow.show();
	$ErrorWindow/Container/ExitBtn.grab_focus();
	$ErrorWindow/Container/ErrorMSG.text = message;
	get_tree().paused = true;
	pass

func _on_ExitBtn_pressed():
	Global.Start_menu_page = errStatus;
	get_tree().change_scene("Menu/StartMenu.tscn");
	pass # Replace with function body.
