extends Node
class_name Levels

# level name, level path, picture path
# id = position in array

const VS_LEVELS = [
		["NSMB 1-1", "res://Levels/NSMB_GreenLand.tscn", "res://Levels/Textures/NSMB_1-1.png"],
		["NSMB Underground", "res://Levels/NSMB_Underground.tscn", "res://Levels/Textures/NSMB_Underground.png"],
		["NSMB Snow", "res://Levels/NSMB_SnowLand.tscn", "res://Levels/Textures/NSMB_IceLevel.png"],
		["NSMB Pipe", "res://Levels/NSMB_Pipeland.tscn", "res://Levels/Textures/NSMB_Pipe.png"],
		["NSMB Castle Squish", "res://Levels/NSMB_SquishCastle.tscn", "res://Levels/Textures/NSMB_Castle.png"],
		
		["Short Level Chaos", "res://Levels/CustomL_ShortFun.tscn", "res://Levels/Textures/CustomL_ShortFun.png"],
		["Custom 1-2", "res://Levels/CustomL_World1-2.tscn", "res://Levels/Textures/CustomL_1-2.png"],
		["Castle Level 1", "res://Levels/CustomL_CastleLike1.tscn", "res://Levels/Textures/CustomL_CastleLike1.png"],
		["Clouds Mountain", "res://Levels/CustomL_CloudsMontain.tscn", "res://Levels/Textures/CloudMontain.png"],
		
		["Castle Level 2", "res://Levels/CustomL_Unnamed1.tscn", "res://Levels/Textures/CustomL_Unnamed1.png"],
		["Unnamed 4", "res://Levels/CustomL_Unnamed4.tscn", "res://Levels/Textures/CustomL_Unnamed4.png"],
		["Pipe Madness", "res://Levels/CustomL_PipeMadness.tscn", "res://Levels/Textures/CustomL_PipeMadness.png"],
		["Vertical Madness", "res://Levels/CustomL_Vertical.tscn", "res://Levels/Textures/CustomL_Vertical.png"],
		
		["Unnamed 5", "res://Levels/CustomL_Unnamed5.tscn", "res://Levels/Textures/CustomL_Unnamed5.png"],
		["Lost Levels Clouds", "res://Levels/CustomL_LostLevelClouds.tscn", "res://Levels/Textures/CustomL_LostLevelClouds.png"],
		["Spikes and Beetles", "res://Levels/CustomL_SpikesAndBeetles.tscn", "res://Levels/Textures/CustomL_SpikesAndBeetles.png"],
	];

func _ready():
	pass # Replace with function body.

func getVsLevels():
	return VS_LEVELS;
	pass

func getVsLevelByID(id):
	if(id > VS_LEVELS.size()):
		return VS_LEVELS[0];
	else:
		return VS_LEVELS[id];
	pass
	
func getRandomVsLevel():
	randomize()
	return VS_LEVELS[rand_range(0, VS_LEVELS.size())];
	pass

func getRandomVsClassicLevel():
	
	pass
