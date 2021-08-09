extends Position2D

export var spawnID = 0;
export (int, \
		"Mode dependent", \
		"idle", \
		"Spawn Warp", \
		"Vertical Pipe Upwards", \
		"Vertical Pipe Downwards", \
		"Horizontal Pipe Right", \
		"Horizontal Pipe Left") var spawnType = 0;
		
export (bool) var differentSpawnForPlayers = false;

export (NodePath) var destinationScene = null;
export var destinationSpawn = 0;

func hasDestinationScene():
	if(destinationScene == null):
		return false;
	else:
		return true;
	pass

#first 10 IDs should be reserved for special spawns (0-3 are for player init spawn)

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
