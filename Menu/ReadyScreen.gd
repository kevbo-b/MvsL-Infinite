extends Node
class_name ReadyScreen

const LUIGI_SHADER = preload("res://Shader/luigi.shader");	
const PLAYER3_SHADER = preload("res://Shader/player3.shader");
const PLAYER4_SHADER = preload("res://Shader/player4.shader");	
const STARMAN_SHADER = preload("res://Shader/starMan.shader");	

var loading_thread = Thread.new();

func _ready():
	get_tree().paused = false;
	resetRoundVariables();
	
	if(Global.deadByTimeUp):
		get_tree().get_root().set_size_override(true, Vector2(455,256));
		setTimeUp();
	elif(Global.is_vs_mode):
		$WholeScreen/CoopScreen.hide();
		$WholeScreen/UpperScreen.show();
		$WholeScreen/LowerScreen.show()
		setPlayerNumber(Global.player_amount);
		$Fade.show();
		fadeIn();
	else: #loading screen like the original SMB
		setPlayerNumberCoop(Global.player_amount);
	pass

func setTimeUp():
	$LoadingIcon.hide()
	$WholeScreen/UpperScreen.hide();
	$WholeScreen/LowerScreen.hide();
	$WholeScreen/CoopScreen.hide();
	$WholeScreen/TimeUp.show();
	
	$WholeScreen/TimeUp/timeUp.start();
	pass

func setPlayerNumberCoop(players):
	$LoadingIcon.hide()
	$WholeScreen/UpperScreen.hide();
	$WholeScreen/LowerScreen.hide();
	$WholeScreen/TimeUp.hide();
	$WholeScreen/CoopScreen.show();
	
	$WholeScreen/CoopScreen/worldEntity/world.text = Global.world_name;
	
	$WholeScreen/CoopScreen/playerEntity/lives.text = str(Global.playerLives[0]);
	
	for i in range(0, Global.player_amount - 1):
		var playerMaterial = getShaderByNumber(i+2);
		var obj = $WholeScreen/CoopScreen/playerEntity.duplicate();
		obj.get_node("player").material = playerMaterial;
		obj.get_node("lives").text = str(Global.playerLives[i+1]);
		$WholeScreen/CoopScreen.add_child(obj)
	
	$WholeScreen/CoopScreen/startingTimer.start();
	pass
	
func getShaderByNumber(num):
	var playerShader;
	var playerMaterial = ShaderMaterial.new();	
	
	if(num == 1):
		pass
	if(num == 2):
		playerShader = LUIGI_SHADER;
	elif(num == 3):
		playerShader = PLAYER3_SHADER;
	elif(num == 4):
		playerShader = PLAYER4_SHADER;
	else:
		playerShader = STARMAN_SHADER;
	
	playerMaterial.shader = playerShader;
	return playerMaterial;
	pass
	
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
	Global.player_amount_local = 0;
	Global.music_coop_initiated = false;
	if(Global.is_vs_mode):
		for i in Global.playerLives:
			i = Global.initialLives;
	pass


func _on_timeUp_timeout():
	$WholeScreen/TimeUp/timeUp.stop();
	Global.deadByTimeUp = false;
	setPlayerNumberCoop(Global.player_amount);
	pass


func _on_startingTimer_timeout():
	$WholeScreen/CoopScreen/startingTimer.stop();
	get_tree().change_scene("Menu/Screen.tscn");
	pass
