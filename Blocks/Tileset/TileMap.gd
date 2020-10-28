extends TileMap
class_name SMBTileMap

export(int, "0 (Green Overworld)","1 (Underground)","2 (Castle)","3 (Snow)","4 (Custom Ice)","5 (Water/World 9)","6 (Red Overworld)") var palette = 0;
export var replaceScriptedBlocks = true;

const BREAKABLE_BLOCK = preload("res://Blocks/BrickBlock.tscn");
const COLLECTABLE_COIN = preload("res://Misc/Coin.tscn");
const INVISIBLE_BLOCK = preload("res://Blocks/InvisibleBlock.tscn");
const QUESTION_BLOCK = preload("res://Blocks/QuestionBlock.tscn");
const HARD_BLOCK = preload("res://Blocks/BreakableBlock.tscn");
const SPIKE = preload("res://Blocks/Spikes.tscn");
const ICE_BLOCK = preload("res://Blocks/IceBlock.tscn");

const THREED_GFX = preload("res://GFX/Tileset/SMB1Tileset3DBG.png")

var doNothing = false;
var is3DBGLayer = false;

func _ready():
	Global.current_tileMap_palette = palette;
	if("3DCanvLayer" in get_parent().name):
		is3DBGLayer = true;
	if(!is3DBGLayer):
		setPalette(palette);
		if(replaceScriptedBlocks):
			replaceTiles();
	pass
	
func replaceTiles():
	
	var pal = palette;
	if(pal == 6):
		pal = 0;
		
	var tiles = self.tile_set.get_tiles_ids();
	
	var hardBrick = [3];
	var brownBlock = [1,2,17,18];
	var coinTile = [5];
	var invisBlock = [4] + range(6,8 + 1);
	var spike = range(9, 16 + 1);
	var questBlock = range(19, 30 + 1) + [57];
	var brownBlContent = range(31, 42 + 1);
	var lostLevelsBrownBl = range(155, 166 + 1) # NAMES of the tiles: range(43, 54 + 1), Names are not IDs for whatever reason.
	var iceBlock = [167, 168];
	
	var cellIdsToModify = [];
	cellIdsToModify += brownBlock; 
	cellIdsToModify += coinTile;
	cellIdsToModify += invisBlock;
	cellIdsToModify += spike;
	cellIdsToModify += questBlock;
	cellIdsToModify += hardBrick;
	cellIdsToModify += brownBlContent;
	cellIdsToModify += lostLevelsBrownBl;
	cellIdsToModify += iceBlock;
	
	for cellID in cellIdsToModify:
		var cells = get_used_cells_by_id(cellID);
		for cell in cells:
			if(cellID in brownBlock): #Brown Brick Block
				var block = BREAKABLE_BLOCK.instance();
				block.position = Vector2(cell.x * cell_quadrant_size, cell.y * cell_quadrant_size);
				block.palette = pal;
				if(cellID == 2 || cellID == 18):
					block.inner_block = true;
				if(cellID == 17 || cellID == 18):
					block.lostLevelsStyle = true;
				get_parent().get_node("Blocks").call_deferred("add_child", block);
			
			elif(cellID in coinTile): #Coin
				var coin = COLLECTABLE_COIN.instance();
				coin.palette = pal;
				coin.position = Vector2(cell.x * cell_quadrant_size, cell.y * cell_quadrant_size);
				get_parent().get_node("Coins").call_deferred("add_child", coin);
				
			elif(cellID in invisBlock):
				var block = INVISIBLE_BLOCK.instance();
				block.position = Vector2(cell.x * cell_quadrant_size, cell.y * cell_quadrant_size);
				block.content = 1;
				block.palette = pal;
				block.initialize();
				if(cellID == 6):
					block.changeAnim("invisible");
				elif(cellID == 7):
					block.changeAnim("defaultBlack");
				elif(cellID == 4):
					block.changeAnim("hardRelay");
				get_parent().get_node("Blocks").call_deferred("add_child", block);
				
			elif(cellID in spike): #Spikes
				var spikes = SPIKE.instance();
				spikes.position = Vector2(cell.x * cell_quadrant_size + 8, cell.y * cell_quadrant_size + 8);
				if(cellID <= 12 && cellID >= 9):
					spikes.triggeringSpike = true;
				
				if(cellID == 10 || cellID == 14):
					spikes.spikeDirection = 1;
				elif(cellID == 11 || cellID == 15):
					spikes.spikeDirection = 2;
				elif(cellID == 12 || cellID == 16):
					spikes.spikeDirection = 3;
				
				get_parent().get_node("Blocks").call_deferred("add_child", spikes);
				
			elif(cellID in questBlock): #Question Block
				var block = QUESTION_BLOCK.instance();
				block.position = Vector2(cell.x * cell_quadrant_size, cell.y * cell_quadrant_size);
				block.palette = pal;
				if(cellID == 57):
					block.alwaysHit = true;
				else:
					block.content = cellID - questBlock[0] + 1;
				get_parent().get_node("Blocks").call_deferred("add_child", block);
			
			elif(cellID in hardBrick): #Hard Brick Block
				var block = HARD_BLOCK.instance();
				block.position = Vector2(cell.x * cell_quadrant_size, cell.y * cell_quadrant_size);
				block.palette = pal;
				get_parent().get_node("Blocks").call_deferred("add_child", block);
				
			elif(cellID in brownBlContent || cellID in lostLevelsBrownBl):
				var block = BREAKABLE_BLOCK.instance();
				block.position = Vector2(cell.x * cell_quadrant_size, cell.y * cell_quadrant_size);
				block.palette = pal;
				if(cellID in lostLevelsBrownBl):
					block.lostLevelsStyle = true;
					block.content = cellID - lostLevelsBrownBl[0] + 1;
				else:
					block.content = cellID - brownBlContent[0] + 1;
				get_parent().get_node("Blocks").call_deferred("add_child", block);
			
			elif(cellID in iceBlock):
				var block = ICE_BLOCK.instance();
				block.position = Vector2(cell.x * cell_quadrant_size, cell.y * cell_quadrant_size);
				block.palette = 4;
				if(cellID == iceBlock[1]):
					block.breakable = true;
				get_parent().get_node("Blocks").call_deferred("add_child", block);
				pass
			
			set_cellv(cell, -1);
				
	pass

func setPalette(pal):
	var tileSet = tile_set.duplicate();
	
	palette = pal;
	var tiles = tileSet.get_tiles_ids();
	for tile in tiles:
		var multiplier;
		var newRect = tileSet.tile_get_region(tile);
		
		if(pal == 1):
			if(newRect.position.y > 16):
				multiplier = 0;
			else:
				multiplier = 1;
		elif(pal == 6):
			if(newRect.position.y > 16):
				multiplier = 1;
			else:
				multiplier = 0;
		else:
			multiplier = pal;
			
		newRect.position.y = newRect.position.y + multiplier * 32;
		
		tileSet.tile_set_region(tile, newRect);
		tile_set = tileSet;
		
		if(is3DBGLayer):
			tileSet.tile_set_texture(tile,THREED_GFX);
		pass
	pass
	
