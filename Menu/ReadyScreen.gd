extends Node
class_name ReadyScreen

const LUIGI_SHADER = preload("res://Shader/luigi.shader");	

var loading_thread = Thread.new();

func _ready():
	get_tree().paused = false;
	resetRoundVariables();
	
	if(Global.is_vs_mode):
		setPlayerNumber(Global.player_amount);
		$Fade.show();
		fadeIn();
	pass # Replace with function body.
	
func setPlayerNumber(players):
	if(players == 2 && !Global.player2LeftRight):
		$WholeScreen/LowerScreen/P4.queue_free();
		$WholeScreen/UpperScreen/P2.queue_free();
		var playerShader;
		var playerMaterial = ShaderMaterial.new();
		playerShader = LUIGI_SHADER;
		playerMaterial.shader = playerShader;
		$WholeScreen/LowerScreen/P3/PlayerBox3/READY.material = playerMaterial;
	else:
		if(players < 4):
			if(players == 3 && !Global.player3BigScreen):
				$WholeScreen/LowerScreen/P4/Label.queue_free();
				$WholeScreen/LowerScreen/P4/PlayerBox4.queue_free();
			else:
				$WholeScreen/LowerScreen/P4.queue_free();
			if(players < 3):
				$WholeScreen/LowerScreen.queue_free();
				if(players < 2):
					$WholeScreen/UpperScreen/P2.queue_free();
	pass

func fadeIn():
	$Fade/FadeAnimationPlayer.play("FadeIn");
	yield($Fade/FadeAnimationPlayer, "animation_finished");
	$TimeTillFadeOut.start();
	pass

func _on_TimeTillFadeOut_timeout():
	$TimeTillFadeOut.stop();
	#loading_thread.start(self,"fadeOut");
	fadeOut();
	pass

func fadeOut():
	$Fade/FadeAnimationPlayer.play("FadeOut");
	yield($Fade/FadeAnimationPlayer, "animation_finished");
	get_tree().change_scene("Menu/Screen.tscn");
	pass
	
func resetRoundVariables():
	Global.playerPositions = [null,null,null,null];
	Global.splitscreen_current_player_hud = 1;
	Global.level_spawns_mega_shroom = true;
	Global.player_instances = []; 
	pass
