extends Node2D

func _ready():
	Global.canvas3DPaths += [str(get_path())];
	pass # Replace with function body.

var deletedBlocks = [];

func deleteInteractiveBlock(xCord, yCord):
	var saveOnce = true;
	for layer in get_children():
		var tileMap = layer.get_child(0);
		if(saveOnce):
			deletedBlocks += [xCord, yCord, tileMap.get_cell(xCord,yCord)];
			saveOnce = false;
		tileMap.set_cell(xCord, yCord , -1);
	pass
	
func restoreAllBlocks():
	for layer in get_children():
		var tileMap = layer.get_child(0);
		var f = 0;
		for i in range(0, deletedBlocks.size() / 3):
			tileMap.set_cell(deletedBlocks[f],deletedBlocks[f+1],deletedBlocks[f+2]);
			f = f + 3;
	deletedBlocks = [];
	pass
	
func setTilemapToAllLayers(tm): #unused
	for layer in get_children():
		var tileMap = layer.get_child(0);
		tileMap.call_deferred("replace_by",tm.duplicate());
	pass
