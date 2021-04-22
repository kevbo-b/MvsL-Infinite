extends Node2D

const OBJ_BASE_CLASS = preload("res://Classes/SMBObjectBaseClass.gd");

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

	var tempOBJ = OBJ_BASE_CLASS.new();
	tempOBJ._ready()
	var distVec = tempOBJ.calcDistanceVector(starVec, arrowVector);
	tempOBJ.queue_free();
	
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
