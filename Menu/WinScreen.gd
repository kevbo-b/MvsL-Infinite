extends Control
class_name win_screen

var winner;
var next_round = true;
var screen;
var winner_string;

func _ready():
	if(Global.DEBUG_MODE):
		$WinMoment.wait_time = 0.05;
		$WinMoment.start()
		$ContinuePopUp.wait_time = 0.1;
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_winner(player, used_screen):
	screen = used_screen;
	winner = player;
	set_points_winner();
	addTotalStarCount();

func set_points_winner():
	if(winner.name == "player"):
		Global.player_1_wins = Global.player_1_wins + 1;
	elif(winner.name == "player2"):
		Global.player_2_wins = Global.player_2_wins + 1;
	elif(winner.name == "player3"):
		Global.player_3_wins = Global.player_3_wins + 1;
	elif(winner.name == "player4"):
		Global.player_4_wins = Global.player_4_wins + 1;
		
	var arr = [Global.player_1_wins,Global.player_2_wins,Global.player_3_wins,Global.player_4_wins];
	for i in arr:
		if(i == Global.wins_to_collect):
			next_round = false;
			$MarginContainer/VBoxContainer/HBoxContainer/Continue.text = "Continue";
	pass

func _on_WinMoment_timeout():
	$WinMoment.stop();
	
	if(winner.personal_name == null):
		winner_string = winner.name;
	else:
		winner_string = winner.personal_name;
	if(winner_string == "player"):
		winner_string = "player1";
		
	$MarginContainer/VBoxContainer/Winner.text = winner_string + " has won!";
	$MarginContainer.visible = true;
	$ContinuePopUp.start();
	
	$WinTheme.play();
	pass

func addTotalStarCount():
	Global.match_star_count[0] += Global.player_current_stars[0];
	Global.match_star_count[1] += Global.player_current_stars[1];
	Global.match_star_count[2] += Global.player_current_stars[2];
	Global.match_star_count[3] += Global.player_current_stars[3];
	pass

func _on_ContinuePopUp_timeout():
	$ContinuePopUp.stop();
	$MarginContainer/VBoxContainer/HBoxContainer/Continue.visible = true;
	$MarginContainer/VBoxContainer/HBoxContainer/Continue.grab_focus();
	pass


func _on_Continue_pressed():
	$FullscreenOverlay/OverlayAnimation.play("FadeOut");
	$FullscreenOverlay.show();
	yield($FullscreenOverlay/OverlayAnimation, "animation_finished")
	if(next_round):
		Global.Start_menu_page = 2;
		get_tree().change_scene("Menu/StartMenu.tscn");
	else:
		#winner menu here
		Global.Start_menu_page = 3;
		Global.winnerName = winner_string;
		get_tree().change_scene("Menu/StartMenu.tscn");
	pass
