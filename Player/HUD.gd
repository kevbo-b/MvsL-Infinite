extends Control

const HUD_STAR = preload("res://Player/HudIcons/starHUD.png");
const HUD_5_STAR = preload("res://Player/HudIcons/star5HUD.png");

const HUD_MAX_STARS_SHADER = preload("res://Shader/starHUDShader.shader");

var size;
var coins = 0;
var stars = 0;

var ingameTime = -1;

var playerName = "MARIO";

var rect_multiplicator = Vector2(1,1);

func _ready():
	if(Global.DEBUG_MODE):
		setTimeLength(0.02)
	
	if(!Global.livesWithVS): # lives are unused
		$Bars/Bar3/LiveCount/Background.hide();
		$Bars/Bar3/LiveEnemyCount/Background.hide();
	
	scale_proper_size();
	$Bars.rect_size = (get_parent().rect_size / rect_scale) * rect_multiplicator
	$Bars/Bar2.rect_min_size = (get_parent().rect_size / rect_scale) * rect_multiplicator
	
	$Transition/Black.rect_size = $Bars.rect_size
	$Transition/Black.show();
		
	resetHUDStars();
	
	if(!Global.decimalStarCounter):
		$Bars/Bar2/Count/Background/Stars.text = "";
		
	if(Global.is_vs_mode):
		hideElementsForSplitscreenVS();

	hideEnemyStarCount();

	setScreenBorders();
	setCoinCount(0);

	Global.splitscreen_current_player_hud = Global.splitscreen_current_player_hud + 1;
	pass

func hideElementsForSplitscreenVS():
	$Bars/Bar1.hide();
	pass

func setScreenBorders():
	
	var childs = $Bars/Bar2/Count/Background.get_children();
	childs.append($Bars/Bar1/Count/Background/Name);
	childs.append($Bars/Bar1/Count2/Background/Coins);
	childs.append($Bars/Bar1/Count4/Background/Coins);
	childs.append($Bars/Bar1/Count3/Background/Coins)
	
	childs += $Bars/Bar3/LiveCount/Background.get_children();
	childs += $Bars/Bar3/LiveEnemyCount/Background.get_children();
	
	for child in childs:
		child.rect_position = Vector2(child.rect_position.x + 10, child.rect_position.y);
		
	for child in $Bars/Bar2/EnemyCount/Background.get_children():
		child.rect_position = Vector2(child.rect_position.x - 10, child.rect_position.y);
	pass
	
func hideEnemyStarCount(): # Enemy Star Count only makes sense online
	for child in $Bars/Bar2/EnemyCount/Background.get_children():
		child.hide()
	pass
	

func only_keep_one_HUD():
	if(Global.splitscreen_current_player_hud != 1):
		set_deferred("visible",false);
	pass

func scale_proper_size():
	if(Global.splitscreen_current_player_hud == 3 && Global.player3BigScreen && Global.player_amount == 3):
		rect_scale = Vector2(3,3); #bigScreen 3 Players
		rect_multiplicator.x = 2;
	elif(Global.player_amount_local == 2 && !Global.player2LeftRight):
		rect_scale = Vector2(3,3); 
		rect_multiplicator.x = 2;
	elif(Global.player_amount_local == 2 && Global.player2LeftRight):
		rect_scale = Vector2(3,3); 
		rect_multiplicator.y = 2;
	elif(Global.player_amount_local > 2):
		rect_scale = Vector2(3,3); 
	else:
		rect_scale = Vector2(4, 4); #1 Player
		rect_multiplicator = Vector2(2,2);
	pass
	
func star_collected():
	var old_stars = stars;
	stars = stars + 1;
	setStarsAtHUD(stars);
	checkForMatchball(old_stars, stars);
	setHighestStarNum();
	pass
	
func star_lost():
	var old_stars = stars;
	stars = stars - 1;
	setStarsAtHUD(stars);
	checkForMatchball(old_stars, stars);
	setHighestStarNum();
	pass
	
func setStarsAtHUD(star_count):
	if(Global.decimalStarCounter || stars > 10):
		$Bars/Bar2/Count/Background/Stars.text = str(star_count) + "/" + str(Global.stars_to_collect);
		resetHUDStars();
	else:
		$Bars/Bar2/Count/Background/Stars.text = "";
		resetHUDStars();
		var fiveStars = 0;
		if(star_count >= 5 && Global.stars_to_collect > 5):
			$Bars/Bar2/Count/Background.get_children()[0].set_texture(HUD_5_STAR);
			star_count = star_count - 4;
			fiveStars = 1;
			
		for i in range(fiveStars,star_count):
			$Bars/Bar2/Count/Background.get_children()[i].set_texture(HUD_STAR);
	pass
	
func resetHUDStars():
	for i in range(0,6):
		$Bars/Bar2/Count/Background.get_children()[i].set_texture(null);
	pass
	
func resetHUDStarsEnemy():
	for i in range(0,6):
		$Bars/Bar2/EnemyCount/Background.get_children()[i].set_texture(null);
	pass
	
func checkForMatchball(prevStarNum, currentStarNum):
	var musicNode = get_node(Global.musicC1_path);
	if(currentStarNum == Global.stars_to_collect - 1):
		setStarHUDShader(true);
		musicNode.addMatchballPlayer();
	else:
		setStarHUDShader(false);
		if(prevStarNum == Global.stars_to_collect - 1 && currentStarNum == prevStarNum - 1):
			musicNode.subMatchballPlayer();
	pass
	
func setHighestStarNum():
	var maximum = 0;
	for stars in Global.player_current_stars:
		if(stars > maximum):
			maximum = stars;
	Global.current_max_stars = maximum;
	pass
	
func setStarHUDShader(param):
	var starShader;
	var starMaterial = ShaderMaterial.new();
	if(param):
		starShader = HUD_MAX_STARS_SHADER;	
		starMaterial.shader = starShader;
		
	if(stars > 10):
		$Bars/Bar2/Count/Background/Stars.material = starMaterial;
	else:
		$Bars/Bar2/Count/Background.material = starMaterial;
		
	pass
	
func setBoxToStarNumber():
	pass
	
func transitionRespawn():
	$Transition/FadeAnimationPlayer.play_backwards("Transition");
	$Transition/FadeAnimationPlayer.seek(0.4, false);
	pass
	
func transitionDead():
	$Transition/FadeAnimationPlayer.play("Transition");
	pass
	
func initCoop():
	
	$Bars/Bar3.hide()
	
	if(!Global.music_coop_initiated):
		var musicNode = get_node(Global.musicC1_path);
		musicNode.allowSpeedupSound(true);
		musicNode.playMusic();
		Global.music_coop_initiated = true;
		
	ingameTime = Global.current_level_settings_node.time;

	resetHUDStarsEnemy();
	$Bars/Bar2/EnemyCount.show();
	$Bars/Bar2/Count/Background/Stars.text = str("00000000")
	$Bars/Bar2/EnemyCount/Background/Stars.text = str(ingameTime);
	
	$Bars/Bar1.show();
	$Bars/Bar1/Count/Background/Name.text = playerName;
	
	$timeSubsctraction.start();
	pass
	#if(!Global.is_vs_mode):
#func _process(delta):
#	pass


func _on_timeSubsctraction_timeout():
	$timeSubsctraction.stop();
	ingameTime -= 1;
	
	$Bars/Bar2/EnemyCount/Background/Stars.text = str(ingameTime);
	
	if(ingameTime == 99):
		var musicNode = get_node(Global.musicC1_path);
		musicNode.setFastPlayback(true);
		
	if(ingameTime == 0 && !Global.deadByTimeUp):
		Global.deadByTimeUp = true;
		timeUp();
	else:
		if(!Global.deadByTimeUp):		
			$timeSubsctraction.start();
	pass # Replace with function body.


func timeUp():
	killAllPlayers();
	$initTimeUp.start();
	pass
	
func killAllPlayers():
	for pl in Global.player_instances:
		pl.dead(false);
	pass

func _on_initTimeUp_timeout():
	timeUpExitToMenu();
	pass

func timeUpExitToMenu():
	get_tree().change_scene("Menu/ReadyScreen.tscn");
	pass

func setTimeLength(sec):
	$timeSubsctraction.wait_time = sec;
	pass

func getTimeLength():
	return $timeSubsctraction.wait_time;
	pass
	
func getCoinCount():
	return coins;
	pass
	
func setCoinCount(a):
	coins = a;
	
	if(Global.is_vs_mode):
		$Bars/Bar2/CoinCount/Background/Coins.text = str(coins) + "/" + str(Global.max_coins);
	else:
		if(coins < 10):
			$Bars/Bar2/CoinCount/Background/Coins.text = "0" + str(coins);
		else:
			$Bars/Bar2/CoinCount/Background/Coins.text = str(coins);
	pass

func decrementLive(amount = 1):
	#...
	pass
	
func incrementLive(amount = 1):
	#...
	pass
