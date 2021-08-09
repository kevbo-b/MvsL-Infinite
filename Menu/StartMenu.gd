extends Control

const MAIN_NSMB_THEME = preload("res://SFX/MusicThemes/nsmb_mainMenu.ogg");
const RESULTS_THEME = preload("res://SFX/MusicThemes/nsmb_vsResults.ogg");
const WIN_THEME = preload("res://SFX/NSMB/BGM_MATCH_WIN.ogg");
const LOSE_THEME = preload("res://SFX/NSMB/BGM_MATCH_LOST.ogg");
const VS_LEVELS = preload("res://Levels/Levels.gd")

const FILE_CRYPT_PASS = "fmmcksnx9a01l";

const SAVE_DIR = "user://saves/"
var options_save_path = SAVE_DIR + "saveData.dat"

var menu_db;

func _ready():
	if(Global.DEBUG_MODE):
		$CenterContainer/StartingMenu/OnlineVS.show()
	
	get_tree().paused = false;
	$VERSION/VersionNr.text = "v. " + Global.VERSION_NUMBER;
	loadSave();
	initSoundBus();
	menu_db = $MenuMusic.get_volume_db();
	get_tree().get_root().set_size_override(true, Vector2(455,256));
	setRandomBackground();
	set_world_sites();
	$MenuMusic.stream = MAIN_NSMB_THEME;
	$MenuMusic.play();
	setMenu();
	pass
	
func saveData():
	var save_data = [
		Global.modern_movement,
		Global.musicEnabled,
		Global.player2LeftRight,
		Global.player3BigScreen,
		Global.inappropriate_mode,
		Global.threeDMode,
		
		$CenterContainer/OnlineMenu/ChooseNetwork/playerNameField.text
	]
	
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
		
	var file = File.new()
	var error = file.open_encrypted_with_pass(options_save_path, File.WRITE, FILE_CRYPT_PASS)
	if error == OK:
		file.store_var(save_data)
		file.close()
		print("data saved")
	pass
	
func loadSave():
	var file = File.new()
	if file.file_exists(options_save_path):
		var error = file.open_encrypted_with_pass(options_save_path, File.READ, FILE_CRYPT_PASS)
		if error == OK:
			var save_data = file.get_var()
			file.close()
			Global.modern_movement = 	save_data[0];
			Global.musicEnabled = 		save_data[1];
			Global.player2LeftRight = 	save_data[2];
			Global.player3BigScreen = 	save_data[3];
			Global.inappropriate_mode = save_data[4];
			Global.threeDMode = 		save_data[5];
			
			$CenterContainer/OnlineMenu/ChooseNetwork/playerNameField.text = save_data[6];
	else:
		print("creating save file, cuz not existent yet")
		saveData();
	pass

func initSoundBus():
		
	var musicDB = Global.MUSIC_BUS_VOLUME;
	var sfx_db = Global.SFX_BUS_VOLUME;
	
	var music_bus = AudioServer.get_bus_index("Music")
	var music_bus_fast = AudioServer.get_bus_index("MusicFast")
	var sounds_bus = AudioServer.get_bus_index("IngameSFX")

	AudioServer.set_bus_volume_db(music_bus, musicDB)
	AudioServer.set_bus_volume_db(music_bus_fast, musicDB)
	AudioServer.set_bus_volume_db(sounds_bus, sfx_db)
	
	if(!Global.musicEnabled):
		setMusic(false);
	pass

func setMenu():
	var menuNr = Global.Start_menu_page;
	if(menuNr == 0): #on launch up
		$CenterContainer/StartingMenu/Splitscreen.grab_focus();
	elif(menuNr == 1): #when coming from end game or something
		$CenterContainer/SplitscreenMenu.visible = false;
		$CenterContainer/VsLevelMenu.visible = false;
		$CenterContainer/OnlineMenu.visible = false;
		
		$FullscreenOverlay.show();
		$FullscreenOverlay/OverlayAnimation.play("FadeIn");
		yield($FullscreenOverlay/OverlayAnimation, "animation_finished");
		$CenterContainer/StartingMenu/Splitscreen.grab_focus();
	elif(menuNr == 2): #stage select screen
		if(Global.world_selection):
			$CenterContainer/StartingMenu.visible = false;
			$CenterContainer/SplitscreenMenu.visible = false;
			$CenterContainer/VsLevelMenu.visible = true;
			$CenterContainer/OnlineMenu.visible = false;
			$FullscreenOverlay.show();
			$FullscreenOverlay/OverlayAnimation.play("FadeIn");
			yield($FullscreenOverlay/OverlayAnimation, "animation_finished");
			$FullscreenOverlay/OverlayAnimation.stop();
			$CenterContainer/VsLevelMenu/WorldSet.get_custom_focus();
		else: #instant start on Random
			startRandomLevel();
	elif(menuNr == 3): #Win Menu
		setWinnerMenu();
pass

func _on_QuitGameButton_pressed():
	get_tree().quit();
	pass

func _on_Splitscreen_pressed():
	$CenterContainer/StartingMenu.visible = false;
	$CenterContainer/SplitscreenMenu.visible = true;
	$CenterContainer/SplitscreenMenu/PlayerAmount/PlayerCount.grab_focus();
	pass

func _on_Back_pressed():
	$CenterContainer/StartingMenu.visible = true;
	$CenterContainer/SplitscreenMenu.visible = false;
	$CenterContainer/StartingMenu/Splitscreen.grab_focus();
	pass

func _on_BackToSplitscreenMenu_pressed():
	$CenterContainer/VsLevelMenu.visible = false;
	$CenterContainer/SplitscreenMenu.visible = true;
	pass

func _on_ConfirmSplitscreenGame_pressed():
	splitscreen_set_global_variables();
	
	if($CenterContainer/SplitscreenMenu/World/WorldSelect.text == "Random"):
		Global.world_selection = false;
		startRandomLevel();
	else:
		$CenterContainer/SplitscreenMenu.visible = false;
		$CenterContainer/VsLevelMenu.visible = true;
		$CenterContainer/VsLevelMenu/WorldSet.get_custom_focus();
	pass

func startRandomLevel():
	var randomLevelGen = RandomNumberGenerator.new();
	randomLevelGen.randomize();
	
	var levels = VS_LEVELS.new()
	var level = levels.getRandomVsLevel();
	
	load_splitscreen_level(level[1]);
	pass

func _on_DecreaseWorld_pressed():
	if($CenterContainer/SplitscreenMenu/World/WorldSelect.text == "Random"):
		$CenterContainer/SplitscreenMenu/World/WorldSelect.text = "Pick";
	else:
		$CenterContainer/SplitscreenMenu/World/WorldSelect.text = "Random";
	pass
	
var max_collectable_stars = 30;

func _on_IncreaseStars_pressed():
	var num = int($CenterContainer/SplitscreenMenu/StarsToWin/StarCount.text);
	num = num + 1;
	if(num > max_collectable_stars):
		num = 3;
	$CenterContainer/SplitscreenMenu/StarsToWin/StarCount.text = str(num);
	pass

func _on_DecreaseStars_pressed():
	var num = int($CenterContainer/SplitscreenMenu/StarsToWin/StarCount.text);
	num = num - 1;
	if(num < 2):
		num = 10;
	$CenterContainer/SplitscreenMenu/StarsToWin/StarCount.text = str(num);
	pass

func _on_IncreaseWins_pressed():
	var num = int($CenterContainer/SplitscreenMenu/Wins/WinCount.text);
	num = num + 1;
	if(num > 10):
		num = 1;
	$CenterContainer/SplitscreenMenu/Wins/WinCount.text = str(num);
	pass

func _on_DecreaseWins_pressed():
	var num = int($CenterContainer/SplitscreenMenu/Wins/WinCount.text);
	num = num - 1;
	if(num < 1):
		num = 10;
	$CenterContainer/SplitscreenMenu/Wins/WinCount.text = str(num);
	pass

func _on_IncreasePlayer_pressed():
	var num = int($CenterContainer/SplitscreenMenu/PlayerAmount/PlayerCount.text);
	num = num + 1;
	if(num > 4):
		num = 1;
	$CenterContainer/SplitscreenMenu/PlayerAmount/PlayerCount.text = str(num);
	pass

func _on_DecreasePlayer_pressed():
	var num = int($CenterContainer/SplitscreenMenu/PlayerAmount/PlayerCount.text);
	num = num - 1;
	if(num < 2):
		num = 4;
	$CenterContainer/SplitscreenMenu/PlayerAmount/PlayerCount.text = str(num);
	pass

func set_world_sites():
	var num = 0; 
	
	for child in $CenterContainer/VsLevelMenu/WorldSet.get_children():
		num = num + 1;
	num = num - 2; #so it doesnt count template worlds
	
	if(num % 3 == 0):
		num = num / 3; #because 3 World-Lines per Site
	else:
		num = num / 3 + 1;
	
	$CenterContainer/VsLevelMenu/ChangeWorldSet/SplitscreenAmountSites.text = str(num);
	pass

func _on_SplitscreenSkipWorldSetRight_pressed():
	var site = int($CenterContainer/VsLevelMenu/ChangeWorldSet/SplitscreenCurrentSite.text);
	var max_sites = int($CenterContainer/VsLevelMenu/ChangeWorldSet/SplitscreenAmountSites.text);
	if(site >= max_sites):
		site = max_sites;
	else:
		site = site + 1;
		change_site_splitscreen(site);
	$CenterContainer/VsLevelMenu/ChangeWorldSet/SplitscreenCurrentSite.text = str(site);
	pass

func change_site_splitscreen(site):

	var site_loop = 1;
	var i = 0;
	
	for child in $CenterContainer/VsLevelMenu/WorldSet.get_children():
		
		if(site_loop == site):
			child.visible = true;
		else:
			child.visible = false;
		i = i + 1;
		if(i >= 3):
			i = 0;
			site_loop = site_loop + 1;
	pass

func _on_SplitscreenSkipWorldSetLeft_pressed():
	var site = int($CenterContainer/VsLevelMenu/ChangeWorldSet/SplitscreenCurrentSite.text);

	if(site <= 1):
		site = 1;
	else:
		site = site - 1;
		change_site_splitscreen(site);
	$CenterContainer/VsLevelMenu/ChangeWorldSet/SplitscreenCurrentSite.text = str(site);
	pass
	
func load_splitscreen_level(level):
	get_tree().get_root().set_disable_input(true);
	if(Global.Start_menu_page != 2 || Global.world_selection):
		$FullscreenOverlay/OverlayAnimation.play("FadeOut");
		$FullscreenOverlay.show();
		yield($FullscreenOverlay/OverlayAnimation, "animation_finished")
	Global.player_amount_local = Global.player_amount;
	Global.is_online_mode  = false;
	Global.playing_splitscreen = true;
	Global.current_max_stars = 0;
	Global.player_current_stars = [0,0,0,0];
	Global.world_to_load = level;
	get_tree().change_scene("Menu/ReadyScreen.tscn");
	get_tree().get_root().set_disable_input(false);
	pass
	
func reset_player_wins():
	Global.player_1_wins = 0;
	Global.player_2_wins = 0;
	Global.player_3_wins = 0;
	Global.player_4_wins = 0;
	Global.match_star_count = [0, 0, 0, 0];
	pass
	
func splitscreen_set_global_variables():
	Global.player_amount = int($CenterContainer/SplitscreenMenu/PlayerAmount/PlayerCount.text);
	Global.stars_to_collect = int($CenterContainer/SplitscreenMenu/StarsToWin/StarCount.text);
	Global.wins_to_collect = int($CenterContainer/SplitscreenMenu/Wins/WinCount.text);
	reset_player_wins();
	if($CenterContainer/SplitscreenMenu/World/WorldSelect.text == "Pick"):
		Global.world_selection = true;
	else:
		Global.world_selection = false;
		
	if(Global.player_amount > 2):
		Global.max_coins = 6;
		if(Global.player_amount == 4):
			Global.max_coins = 4;
	else:
		Global.max_coins = 8;
	pass
	
# Should change to Array of levels, rather than taking them from Main-Menu configurations.
# Main Menu should only load this Array rather than beeing the save for it itself
func level_selected(level_name): 
	if(!Global.DEBUG_MODE && level_name == "default_level"):
		startRandomLevel();
	else:
		load_splitscreen_level(level_name);
	pass

func _on_BackSoloMenu_pressed():
	$CenterContainer/StartingMenu.visible = true;
	$CenterContainer/CoopSoloMenu.visible = false;
	$CenterContainer/StartingMenu/StartGameButton.grab_focus();
	pass

func _on_DecreasePlayerCoop_pressed():
	var num = int($CenterContainer/CoopSoloMenu/PlayerAmount/PlayerCountCoop.text);
	num = num - 1;
	if(num < 1):
		num = 4;
	$CenterContainer/CoopSoloMenu/PlayerAmount/PlayerCountCoop.text = str(num);
	pass # Replace with function body.

func _on_IncreasePlayerCoop_pressed():
	var num = int($CenterContainer/CoopSoloMenu/PlayerAmount/PlayerCountCoop.text);
	num = num + 1;
	if(num > 4):
		num = 1;
	$CenterContainer/CoopSoloMenu/PlayerAmount/PlayerCountCoop.text = str(num);
	pass # Replace with function body.

func _on_ConfirmCoopGame_pressed():
	#$CenterContainer/StartingMenu.visible = true; game choose menu here
	$CenterContainer/CoopSoloMenu.visible = false;
	#$CenterContainer/StartingMenu/StartGameButton.grab_focus(); grab in gem menu
	pass # Replace with function body.

func setRandomBackground():
	var backgrounds = [];
	backgrounds += ["PipeSewers.png"];
	backgrounds += ["koopaBG.jpg"];
	backgrounds += ["starsBG.jpg"];
	backgrounds += ["redCave.png"];
	backgrounds += ["blueCave.png"];
	backgrounds += ["sandStars.png"];
	
	var bgRandomGen = RandomNumberGenerator.new();
	bgRandomGen.randomize();
	var number = bgRandomGen.randi()%backgrounds.size();

	var fullPicturePath = "res://Menu/Backgrounds/" + backgrounds[number];
	$BackgroundControl/BackgroundPicture.texture = load(fullPicturePath);
	pass

func _on_MainMenuAfterWin_pressed():
	$CenterContainer/WinnerMenu.visible = false;
	$CenterContainer/StartingMenu.visible = true;
	$CenterContainer/StartingMenu/Splitscreen.grab_focus();
	
	$CenterContainer/WinnerMenu/WinSoundMoment.stop();
	$MenuMusic.set_volume_db(menu_db);
	$MenuMusic.stream = MAIN_NSMB_THEME;
	$MenuMusic.play();
	pass

func setWinnerMenu():
	$CenterContainer/WinnerMenu.visible = true;
	$CenterContainer/StartingMenu.visible = false;
	$CenterContainer/SplitscreenMenu.visible = false;
	$CenterContainer/WinnerMenu/Bar2/WinnerName.text = Global.winnerName;
	
	if($CenterContainer/WinnerMenu/Bar2/WinnerName.text == "player"):
		$CenterContainer/WinnerMenu/Bar2/WinnerName.text == "player 1";
	
	$CenterContainer/WinnerMenu/P1/P1Wins.text = str(Global.player_1_wins);
	$CenterContainer/WinnerMenu/P2/P2Wins.text = str(Global.player_2_wins);
	$CenterContainer/WinnerMenu/P3/P3Wins.text = str(Global.player_3_wins);
	$CenterContainer/WinnerMenu/P4/P4Wins.text = str(Global.player_4_wins);
	
	$CenterContainer/WinnerMenu/P1/P1Stars.text = str(Global.match_star_count[0]);
	$CenterContainer/WinnerMenu/P2/P2Stars.text = str(Global.match_star_count[1]);
	$CenterContainer/WinnerMenu/P3/P3Stars.text = str(Global.match_star_count[2]);
	$CenterContainer/WinnerMenu/P4/P4Stars.text = str(Global.match_star_count[3]);
	
	if(Global.player_amount < 4):
		$CenterContainer/WinnerMenu/P4.hide();
		if(Global.player_amount < 3):
			$CenterContainer/WinnerMenu/P3.hide();
			if(Global.player_amount < 2):
				$CenterContainer/WinnerMenu/P2.hide();
				
	$MenuMusic.stream = WIN_THEME;
	$MenuMusic.play();
	$CenterContainer/WinnerMenu/WinSoundMoment.start();
				
	$FullscreenOverlay.show();
	$FullscreenOverlay/OverlayAnimation.play("FadeIn");
	yield($FullscreenOverlay/OverlayAnimation, "animation_finished");
	$CenterContainer/WinnerMenu/Start/MainMenuAfterWin.grab_focus();
	pass

func _on_OptionsButton_pressed():
	if(Global.musicEnabled):
		$CenterContainer/OptionsMenu/Op1/MusicBtn.text = "ON"
	else:
		$CenterContainer/OptionsMenu/Op1/MusicBtn.text = "OFF"
		
	if(Global.player3BigScreen):
		$CenterContainer/OptionsMenu/Op2/SplitscreenPlayer3.text = "ON"
	else:
		$CenterContainer/OptionsMenu/Op2/SplitscreenPlayer3.text = "OFF"
		
	if(Global.inappropriate_mode):
		$CenterContainer/OptionsMenu/Op3/InapropiateMode.text = "ON"
	else:
		$CenterContainer/OptionsMenu/Op3/InapropiateMode.text = "OFF"
	
	if(Global.player2LeftRight):
		$CenterContainer/OptionsMenu/Op4/LeftRight2Player.text = "ON"
	else:
		$CenterContainer/OptionsMenu/Op4/LeftRight2Player.text = "OFF"
		
	if(Global.modern_movement):
		$CenterContainer/OptionsMenu/Op5/MovementBtn.text = "ON"
	else:
		$CenterContainer/OptionsMenu/Op5/MovementBtn.text = "OFF"
		
	if(Global.threeDMode):
		$CenterContainer/OptionsMenu/Op6/Btn3DMode.text = "ON"
	else:
		$CenterContainer/OptionsMenu/Op6/Btn3DMode.text = "OFF"
	
	$CenterContainer/StartingMenu.hide();
	$CenterContainer/OptionsMenu.show();
	$CenterContainer/OptionsMenu/Op5/MovementBtn.grab_focus();
	pass # Replace with function body.

func setMusic(param):
	var music_bus = AudioServer.get_bus_index("Music")
	var music_bus_fast = AudioServer.get_bus_index("MusicFast")
	
	if(param == false):
		AudioServer.set_bus_mute(music_bus, true);
		AudioServer.set_bus_mute(music_bus_fast, true);
		$MenuMusic.stop();
	else:
		AudioServer.set_bus_mute(music_bus, false);
		AudioServer.set_bus_mute(music_bus_fast, false);
		if(!$MenuMusic.is_playing()):
			$MenuMusic.play();
	pass

func _on_SaveBack_pressed():
	$CenterContainer/OptionsMenu.hide();
	$CenterContainer/StartingMenu.show();
	$CenterContainer/StartingMenu/Splitscreen.grab_focus();
	
	if($CenterContainer/OptionsMenu/Op1/MusicBtn.text == "OFF"):
		Global.musicEnabled = false;
		setMusic(false);
	else:
		Global.musicEnabled = true;
		setMusic(true);
		
	if($CenterContainer/OptionsMenu/Op2/SplitscreenPlayer3.text == "OFF"):
		Global.player3BigScreen = false;
	else:
		Global.player3BigScreen = true;
		
	if($CenterContainer/OptionsMenu/Op3/InapropiateMode.text == "OFF"):
		Global.inappropriate_mode = false;
	else:
		Global.inappropriate_mode = true;
		
	if($CenterContainer/OptionsMenu/Op4/LeftRight2Player.text == "OFF"):
		Global.player2LeftRight = false;
	else:
		Global.player2LeftRight = true;
		
	if($CenterContainer/OptionsMenu/Op5/MovementBtn.text == "OFF"):
		Global.modern_movement = false;
	else:
		Global.modern_movement = true;
		
	if($CenterContainer/OptionsMenu/Op6/Btn3DMode.text == "OFF"):
		Global.threeDMode = false;
	else:
		Global.threeDMode = true;
	
	saveData();
	printNotification("Settings saved.");
	pass

func _on_DiscardOptions_pressed():
	$CenterContainer/OptionsMenu.hide();
	$CenterContainer/StartingMenu.show();
	$CenterContainer/StartingMenu/OptionsButton.grab_focus();
	printNotification("Settings discarded.");
	pass

func _on_MusicBtn_pressed():
	if($CenterContainer/OptionsMenu/Op1/MusicBtn.text == "OFF"):
		$CenterContainer/OptionsMenu/Op1/MusicBtn.text = "ON"
	else:
		$CenterContainer/OptionsMenu/Op1/MusicBtn.text = "OFF"
	pass # Replace with function body.

func _on_SplitscreenPlayer3_pressed():
	if($CenterContainer/OptionsMenu/Op2/SplitscreenPlayer3.text == "OFF"):
		$CenterContainer/OptionsMenu/Op2/SplitscreenPlayer3.text = "ON"
	else:
		$CenterContainer/OptionsMenu/Op2/SplitscreenPlayer3.text = "OFF"
	pass # Replace with function body.

func _on_InapropiateMode_pressed():
	if($CenterContainer/OptionsMenu/Op3/InapropiateMode.text == "OFF"):
		$CenterContainer/OptionsMenu/Op3/InapropiateMode.text = "ON"
	else:
		$CenterContainer/OptionsMenu/Op3/InapropiateMode.text = "OFF"
	pass # Replace with function body.
	
func _on_Btn3DMode_pressed():
	if($CenterContainer/OptionsMenu/Op6/Btn3DMode.text == "OFF"):
		$CenterContainer/OptionsMenu/Op6/Btn3DMode.text = "ON"
	else:
		$CenterContainer/OptionsMenu/Op6/Btn3DMode.text = "OFF"
	pass # Replace with function body.

func _on_LeftRight2Player_pressed():
	if($CenterContainer/OptionsMenu/Op4/LeftRight2Player.text == "OFF"):
		$CenterContainer/OptionsMenu/Op4/LeftRight2Player.text = "ON"
	else:
		$CenterContainer/OptionsMenu/Op4/LeftRight2Player.text = "OFF"
	pass # Replace with function body.

func _on_MovementBtn_pressed():

	if($CenterContainer/OptionsMenu/Op5/MovementBtn.text == "OFF"):
		$CenterContainer/OptionsMenu/Op5/MovementBtn.text = "ON"
	else:
		$CenterContainer/OptionsMenu/Op5/MovementBtn.text = "OFF"
	pass # Replace with function body.

func printNotification(message):
	$PopupMsg.show();
	$PopupMsg/TextLabel.text = message;
	
	var timeVisible = 2;
	
	var t = Timer.new()
	t.set_wait_time(timeVisible)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free();	
	
	$PopupMsg.hide();
	pass

func _on_WinSoundMoment_timeout():
	$CenterContainer/WinnerMenu/WinSoundMoment.stop();
	$MenuMusic.set_volume_db(3);
	$MenuMusic.stream = RESULTS_THEME;
	$MenuMusic.play();
	pass


func _on_OnlineVS_pressed():
	$CenterContainer/StartingMenu.hide();
	$CenterContainer/OnlineMenu.show();
	$CenterContainer/OnlineMenu/ChooseNetwork/Host/SelectHost.grab_focus();
	pass


func _on_BackFromOnline_pressed():
	$CenterContainer/OnlineMenu.hide();
	$CenterContainer/StartingMenu.show();
	$CenterContainer/StartingMenu/OnlineVS.grab_focus();
	pass # Replace with function body.


func _on_CoopButton_pressed(): # UNUSED, coop was once planned.
	$CenterContainer/StartingMenu.visible = false;
	$CenterContainer/CoopSoloMenu.visible = true;
	$CenterContainer/CoopSoloMenu/PlayerAmount/PlayerCountCoop.grab_focus();
	pass


func _on_SelectHost_pressed():
	saveData() #for name
	
	initializeHost()
	$CenterContainer/OnlineMenu/ChooseNetwork.hide()
	setHostLobby()
	$CenterContainer/OnlineMenu/Lobby.show()
	
	$CenterContainer/OnlineMenu/Lobby/infos/HostStats/PortNumber.text = str(Network.DEFAULT_PORT);
	
	refreshLobbyList()
	pass # Replace with function body.


func _on_SelectClient_pressed():
	saveData() #for name
	
	$CenterContainer/OnlineMenu/ChooseNetwork.hide()
	$CenterContainer/OnlineMenu/connectingScreen.show()
	$CenterContainer/OnlineMenu/connectingScreen/BackBar/AbordConnection.grab_focus()
	pass # Replace with function body.

func initializeHost():
	var playerName = $CenterContainer/OnlineMenu/ChooseNetwork/playerNameField.text;
	if(playerName == ""):
		printNotification("Invalid Name.")
	else:
		Network.create_server(playerName);
	
	$CenterContainer/OnlineMenu/Lobby/updateLobbyPlayerinfo.start()
	#start game here ?
	pass
	
	
func initializeClient():
	var playerName = $CenterContainer/OnlineMenu/ChooseNetwork/playerNameField.text;
	if(playerName == ""):
		printNotification("Invalid Name.")
	else:
		Network.connect_to_server(playerName);
	
	#start game here ?
	pass


func _on_CloseLobby_pressed():
	$CenterContainer/OnlineMenu/Lobby.hide()
	$CenterContainer/OnlineMenu/ChooseNetwork.show()
	$CenterContainer/OnlineMenu/ChooseNetwork/Host/SelectHost.grab_focus();
	
	# set client as disconnected

	if(!get_tree().is_network_server()):
		Network.clientConnected = -1;

	# closing server
	get_tree().network_peer = null
	Network.players = {};

	$CenterContainer/OnlineMenu/Lobby/updateLobbyPlayerinfo.stop()
	$CenterContainer/OnlineMenu/connectingScreen/checkIfConnectedAsClient.stop() # needed ?
	pass


func _on_AbordConnection_pressed():
	$CenterContainer/OnlineMenu/connectingScreen.hide()
	$CenterContainer/OnlineMenu/ChooseNetwork.show()
	$CenterContainer/OnlineMenu/ChooseNetwork/Host/SelectHost.grab_focus();
	get_tree().network_peer = null
	Network.players = {};
	$CenterContainer/OnlineMenu/Lobby/updateLobbyPlayerinfo.stop() # needed? 
	$CenterContainer/OnlineMenu/Lobby/updateLobbyPlayerinfo.stop()
	pass


func _on_ConnectToHost_pressed():
	printNotification("Connecting to Host...")
	initializeClient()
	$CenterContainer/OnlineMenu/connectingScreen/checkIfConnectedAsClient.start()
	pass



func _on_updateLobbyPlayerinfo_timeout():
	$CenterContainer/OnlineMenu/Lobby/updateLobbyPlayerinfo.stop()

	#print(Network.players)
	#reset fist
	
	if(get_tree().is_network_server()): # when HOST
		
		refreshLobbyList()
		$CenterContainer/OnlineMenu/Lobby/StartGame/StartGame.disabled = !(Network.players.size() > 1);
		
		#Network.syncData()
		$CenterContainer/OnlineMenu/Lobby/updateLobbyPlayerinfo.start()
	
	else:
		if(Network.clientConnected != 1):
			get_tree().network_peer = null
			if(Network.clientConnected == -2):
				printNotification("Server disconnected.");
			else:
				printNotification("Disconnected")
			$CenterContainer/OnlineMenu/Lobby.hide()
			$CenterContainer/OnlineMenu/ChooseNetwork.show()
			$CenterContainer/OnlineMenu/ChooseNetwork/Client/SelectClient.grab_focus();
		else:
			refreshLobbyList()
			$CenterContainer/OnlineMenu/Lobby/updateLobbyPlayerinfo.start()	
	

	pass

func refreshLobbyList():
	for row in $CenterContainer/OnlineMenu/Lobby/ConnectedPlayers.get_children():
		row.get_node("playerName").text = "..."; 
	
	var i = 1;
	for id in Network.players:
		var playerInfo = Network.players[id]
		get_node("CenterContainer/OnlineMenu/Lobby/ConnectedPlayers/Player" + str(i) + "/playerName").text = playerInfo.name;
		i += 1;
	pass

func _on_checkIfConnectedAsClient_timeout():
	$CenterContainer/OnlineMenu/connectingScreen/checkIfConnectedAsClient.stop()
	
	if(Network.clientConnected == 1):
		printNotification("Connection successfull!")
		$CenterContainer/OnlineMenu/Lobby/updateLobbyPlayerinfo.start()
		
		#initiate menu"
		$CenterContainer/OnlineMenu/connectingScreen.hide()
		setClientLobby()
		$CenterContainer/OnlineMenu/Lobby.show()
	elif(Network.clientConnected == 0):
		printNotification("Connection failed!")
	else:
		$CenterContainer/OnlineMenu/connectingScreen/checkIfConnectedAsClient.start()
	pass


func setClientLobby():
	$CenterContainer/OnlineMenu/Lobby/StartGame.hide()
	$CenterContainer/OnlineMenu/Lobby/BackBar/CloseLobby.grab_focus()
	$CenterContainer/OnlineMenu/Lobby/BackBar/CloseLobby.text = "<- Leave Lobby"
	pass
	
func setHostLobby():
	$CenterContainer/OnlineMenu/Lobby/StartGame.show()
	$CenterContainer/OnlineMenu/Lobby/StartGame/StartGame.grab_focus()
	$CenterContainer/OnlineMenu/Lobby/BackBar/CloseLobby.text = "<- Close Lobby"
	pass


func _on_OnlineStartGame_pressed():
	
	var levels = VS_LEVELS.new()
	var level = levels.getRandomVsLevel();

	Network.initStartLevel(level);
	pass
