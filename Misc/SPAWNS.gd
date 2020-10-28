extends Node2D

func _ready():
	Global.spawns_path = self.get_path();
	pass

func getSpawnByID(id):
	var spawns = get_children();
	var spawnNode = null;
	
	for spawn in spawns:
		if(spawn.spawnID == id):
			spawnNode = spawn;
			break;
			
	return spawnNode;
	pass
	
func getDestinationBySpawnID(id):
	var spawn = getSpawnByID(id);
	if(spawn == null):
		return getSpawnByID(0);
	else:
		var spawnDest = getSpawnByID(spawn.destinationSpawn);
		if(spawnDest == null):
			return getSpawnByID(0);
		else:
			return spawnDest;
	pass

#func _process(delta):
#	pass
