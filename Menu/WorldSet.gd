extends VBoxContainer

const LEVEL_OBJ = preload("res://Levels/Levels.gd")
const NSMB_LEVELS_OWN_PAGE = true; # takes first 5 Level entries and arranges them differently

func _ready():
	setLevels();
	$TEMPLATE_LEVEL.queue_free()
	$TEMPLATE_ROW.queue_free()
	pass 
	
func setLevels():
	
	var levelsObj = LEVEL_OBJ.new()
	
	var i = 0; #level
	var w = 1;
	var current_row = null;
	
	for level in levelsObj.getVsLevels():
		if(i == 0):
			current_row = $TEMPLATE_ROW.duplicate();
			if(!(NSMB_LEVELS_OWN_PAGE && w <= 2)):
				$TEMPLATE_ROW.alignment = BoxContainer.ALIGN_BEGIN;
			current_row.name = str("World " + str(w));
			current_row.show()
			if(NSMB_LEVELS_OWN_PAGE && w == 3):
				add_child($TEMPLATE_ROW.duplicate()); # empty row
			add_child(current_row);
			
		var level_button = $TEMPLATE_LEVEL.duplicate();
		level_button.get_child(0).texture = load(level[2]);
		level_button.name = level[0];
		level_button.show()
		level_button.connect("pressed", get_tree().get_current_scene(), "level_selected", [level[1]]);
		
		current_row.add_child(level_button);
		
		if(w > 3):
			current_row.hide()
		
		i = i + 1;
		if (i == 4):
			i = 0;
			w = w + 1;
			
		if(NSMB_LEVELS_OWN_PAGE):
			
			if(w > 2):
				current_row.hide()
				
			if(i == 3 && w == 1):
				i = 0;
				w = 2;
			
		if(NSMB_LEVELS_OWN_PAGE && i == 2 && w == 2):
			i = 0;
			w = 3;
	pass
	


func get_custom_focus():
	get_node("World 1").get_child(0).grab_focus();
	pass
