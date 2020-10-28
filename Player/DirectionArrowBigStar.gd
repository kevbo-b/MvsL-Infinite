extends Node2D

var starNode;
var distance = 0;
export var showDistance = false;

var inactive = true;

func _ready():
	$VBoxContainer/Display.text = "";
	hide();
	if(Global.is_vs_mode):
		starNode = get_parent().get_parent().get_node("BigStarPositions").get_node("BigStar");
	else:
		queue_free();
	pass

func _process(delta):
	if(!inactive):
		calculateDistanceToStar();
		if(showDistance):
			$VBoxContainer/Display.text = str(int(distance * 100) / 100.0);
	pass

func calculateDistanceToStar():
	var arrowVector = $VBoxContainer/Arrow.get_global_transform()[2];

	var starVec = starNode.position;
	
	if(Global.level_infinite_horizontal_scroll):
		var switchPoint;
		if(starVec.x < Global.level_boundary_rect.position.x + 0.5 * Global.level_boundary_rect.size.x):
			switchPoint = starVec.x + 0.5 * Global.level_boundary_rect.size.x;
			if(arrowVector.x > switchPoint):
				starVec.x = starVec.x + Global.level_boundary_rect.size.x;
		else:
			switchPoint = starVec.x - 0.5 * Global.level_boundary_rect.size.x;
			if(arrowVector.x < switchPoint):
				starVec.x = starVec.x - Global.level_boundary_rect.size.x;
				
	if(Global.level_infinite_vertical_scroll):
		var switchPoint;
		if(starVec.y < Global.level_boundary_rect.position.y + 0.5 * Global.level_boundary_rect.size.y):
			switchPoint = starVec.y + 0.5 * Global.level_boundary_rect.size.y;
			if(arrowVector.y > switchPoint):
				starVec.y = starVec.y + Global.level_boundary_rect.size.y;
		else:
			switchPoint = starVec.y - 0.5 * Global.level_boundary_rect.size.y;
			if(arrowVector.y < switchPoint):
				starVec.y = starVec.y - Global.level_boundary_rect.size.y;
	
	var distVec = starVec - arrowVector;
	distance = sqrt(pow(distVec.x, 2) + pow(distVec.y, 2));
	var angle = (atan2(distVec.y, distVec.x)) * (180.0 / PI);

	$VBoxContainer/Arrow.set_rotation_degrees(angle + 90);
	pass
	
func starSpawned():
	inactive = false;
	show();
	$AnimPlayer.play("FadeOut");
	yield($AnimPlayer,"animation_finished");
	hide();
	inactive = true;
	pass
