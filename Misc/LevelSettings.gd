extends Node2D

export (int, \
	"None", \
	"Random VS Song", \
	"SMB1 Overworld", \
	"SMB1 Overworld (Fast)", \
	"SMB1 Underground", \
	"SMB1 Underground (Fast)", \
	"SMB1 Water", \
	"SMB1 Water (Fast)", \
	"SMB1 Castle", \
	"SMB1 Castle (Fast)", \
	"SMB1 Clouds", \
	"SMB1 Clouds (Fast)", \
	"VS NSMB Theme 1", \
	"VS NSMB Theme 2", \
	"VS SMB1 Remix Theme") var musicTheme = 1;
	
export var repeatingHorizontally = false;
export var repeatingVertically = false;

export var blocksSpaceTop = 0;
export var blocksSpaceButtom = 0;
export var blocksSpaceLeft = 0;
export var blocksSpaceRight = 0;

export var canSpawnMegaInLevel = true;

func _ready():
	pass

func getSongFile(): 

	var i = musicTheme;
	
	# [0] songFileName
	# [1] changeableSpeed (if you can change the speed of the songFile), false for _hurry files
	# [2] only if [1] T: change Songspeed with bus? (if false, it will search for _hurry file!)
	
	if(i == 1):
		return ["vs_random", true, true];
	elif(i == 2):
		return ["smb_overworld", true, false];
	elif(i == 3):
		return ["smb_overworld_hurry", false, false];
	elif(i == 4):
		return ["smb_underground", true, false];
	elif(i == 5):
		return ["smb_underground_hurry", false, false];
	elif(i == 6):
		return ["smb_water", true, false];
	elif(i == 7):
		return ["smb_water_hurry", false, false];
	elif(i == 8):
		return ["smb_castle", true, false];
	elif(i == 9):
		return ["smb_castle_hurry", false, false];
	elif(i == 10):
		return ["smb_invincible", true, false];
	elif(i == 11):
		return ["smb_invincible_hurry", false, false];
	elif(i == 12):
		return ["vs_nsmb_theme_1", true, true];
	elif(i == 13):
		return ["vs_nsmb_theme_2", true, true];
	elif(i == 14):
		return ["vs_theme_8bit", true, true];
	else:
		return null;
	pass

func setScrollProperties():
	Global.level_infinite_horizontal_scroll = repeatingHorizontally;
	Global.level_infinite_vertical_scroll = repeatingVertically;
	
	if(Global.infinite_vertical_all_levels && !repeatingVertically):
		blocksSpaceButtom = 2;
		blocksSpaceTop = 2;
		Global.level_infinite_vertical_scroll = true;
	
	Global.world_spacing_end = Vector2(blocksSpaceRight, blocksSpaceButtom);
	Global.world_spacing_position = Vector2(blocksSpaceLeft, blocksSpaceTop);
	
	Global.level_spawns_mega_shroom = canSpawnMegaInLevel;
	pass
