extends Control
class_name PauseScreen

var pauser;
var next_round = true;
var screen;

func _ready():
	pass # Replace with function body.

func set_pause(player, used_screen):
	pauser = player;
	screen = used_screen;
	if(Global.inappropriate_mode):
		set_inappropriate_text();
	$PauseMenu.visible = true;
	$PauseMenu/VBoxContainer/HBoxContainer/VBoxContainer/Continue.grab_focus();
	
func exit_game():
	Global.Start_menu_page = 1;
	get_tree().get_root().set_disable_input(true);
	$FullscreenOverlay/OverlayAnimation.play("FadeOut");
	$FullscreenOverlay.show();
	yield($FullscreenOverlay/OverlayAnimation, "animation_finished")
	get_tree().change_scene("Menu/StartMenu.tscn");
	get_tree().paused = false;
	get_tree().get_root().set_disable_input(false);
	pass

func _on_Continue_pressed():
	get_tree().paused = false;
	$PauseMenu.visible = false;
	pass

func _on_End_pressed():
	$PauseMenu.visible = false;
	$QuitMenu.visible = true;
	$QuitMenu/VBoxContainer/HBoxContainer/VBoxContainer/Cancel.grab_focus();
	pass

func _on_Cancel_pressed():
	$QuitMenu.visible = false;
	$PauseMenu.visible = true;
	$PauseMenu/VBoxContainer/HBoxContainer/VBoxContainer/End.grab_focus();
	pass
	
func _on_ConfirmEnd_pressed():
	exit_game();
	pass

func set_inappropriate_text():
	$PauseMenu/VBoxContainer/Info.text = "PAUSE XD";
	$PauseMenu/VBoxContainer/HBoxContainer/VBoxContainer/Continue.text = "pause is for noobs";
	$PauseMenu/VBoxContainer/HBoxContainer/VBoxContainer/End.text = "gtfo of here";
	
	$QuitMenu/VBoxContainer/Info.text = "This is unfinished business.\nReally wanna gtfo now?";
	$QuitMenu/VBoxContainer/HBoxContainer/VBoxContainer/Cancel.text = "nah";
	$QuitMenu/VBoxContainer/HBoxContainer/VBoxContainer/ConfirmEnd.text = "fuck off mate";
	pass
