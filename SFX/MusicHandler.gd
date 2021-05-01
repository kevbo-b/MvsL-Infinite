extends AudioStreamPlayer

const MEGASHROOM_THEME = preload("res://SFX/NSMB/nsmb_MegaShroom.ogg");
const STAR_THEME = preload("res://SFX/MusicThemes/smb_invincible.ogg");
const WARNING_THEME = preload("res://SFX/8bitSMB/smb_warning.wav");
const SOUND_DEAD = preload("res://SFX/8bitSMB/smb_mariodie.wav");

var isEnabled = true;

var randomSongIsGenerated = false;

var speedChangable = true;
var isFast = false;
var hasHurryFile = true; #True when fast theme avaiable. Then gets fasten up with Bus

var deadPlayers = Global.player_amount_local;
var initlocalPlayerAmount = false;

var matchballPlayers = 0;
var playSpeedupSound = false;

var songPath = "res://SFX/MusicThemes/";
var songFileName = "";
var hurryExtension = "";
var fileExtension = ".ogg";
var fileArr= [];

func _ready():
	isEnabled = Global.musicEnabled;
	pass

func playMusic(fastCheck = true):
	if(fastCheck):
		initializeSpeed();
	if(isEnabled && fileArr!= null):
		loadSong();
		play();
	pass
	
func loadSong():
	if("vs_random" in songFileName):
		chooseRandomVSSong();
		
	if("vs_theme_8bit" in songFileName):
		set_volume_db(-1);
	elif("vs_nsmb_theme_2" in songFileName):
		set_volume_db(6);
	elif("vs_nsmb_theme_1" in songFileName):
		set_volume_db(5);
	else:
		set_volume_db(7);
	stream = load(songPath + songFileName+ hurryExtension + fileExtension);
	pass

func stopMusic():
	stop();
	pass
	
func speedUp():
	if(speedChangable && fileArr!= null):
		if(playSpeedupSound):
			set_volume_db(4);
			stream = WARNING_THEME;
			play();
			yield(self,"finished");

		if(stream != SOUND_DEAD):

			if(!hasHurryFile):
				bus = "MusicFast";
				pitch_scale = 1.33333333;
				if(playSpeedupSound):
					playMusic(false); #risky for circular dependency
			else:
				if(hurryExtension == ""): #so it doesnt reset when song is already fast
					hurryExtension = "_hurry";
					playMusic(false); #risky for circular dependency

	pass
	
func normalizeSpeed():
	if(speedChangable && fileArr!= null):
		if(!hasHurryFile):
			bus = "Music";
			pitch_scale = 1.0;
		else:
			hurryExtension = "";
			if(deadPlayers == 0):
				playMusic(false); #risky for circular dependency
	pass
	
func chooseRandomVSSong():
	if(!randomSongIsGenerated):
		hasHurryFile = false;
		
		var songs = [];
		songs += ["vs_nsmb_theme_1"];
		songs += ["vs_nsmb_theme_2"];
		songs += ["vs_theme_8bit"];
		
		randomize();
		var number = randi()%songs.size();
		
		songFileName= songs[number];
		randomSongIsGenerated = true;
	pass
	
	# [0] songFileName
	# [1] canMakeFaster (if you can change the speed of the songFile), false for _hurry files
	# [2] hasFasterMusicFile (if true, upgrades with _hurry, if not, with bus) ([1] has to be true)
	
func setSongtrack(fileArray):
	
	fileArr = fileArray;
	
	songFileName = fileArray[0];
	hasHurryFile = fileArray[2];
	speedChangable = fileArray[1];
	pass
	
func playerRespawned(player):
	if(!initlocalPlayerAmount):
		getLocalPlayerAmount();
		initlocalPlayerAmount = true;
	if(player.is_local_player):
		deadPlayers -= 1;
		if(deadPlayers == 0):
			stream = null;
			decideIfFast();
			playMusic();
	pass
	
func playerDied(player):
	if(player.is_local_player):
		deadPlayers += 1;
		stopMusic();
		set_volume_db(0);
		stream = SOUND_DEAD;
		normalizeSpeed();
		play();
	pass
	
func initializeSpeed():
	if(isFast):
		speedUp();
	else:
		normalizeSpeed();
	pass
	
func addMatchballPlayer():
	matchballPlayers+=1;
	decideIfFast();
	initializeSpeed();
	pass
	
func subMatchballPlayer():
	matchballPlayers-=1;
	decideIfFast();
	initializeSpeed();
	pass
	
func decideIfFast():
	if(matchballPlayers <= 0):
		isFast = false
	else: 
		isFast = true
	pass

func setFastPlayback(val):
	if(val == true):
		isFast = true;
	else:
		isFast = false;
	initializeSpeed();
	pass
	
func playMegaShroomTheme(player):
	if(player.is_local_player):
		stream = MEGASHROOM_THEME;
		set_volume_db(10);
		normalizeSpeed();
		play();
	pass
	
func allowSpeedupSound(val):
	if(val == true):
		playSpeedupSound = true;
	else:
		playSpeedupSound = false;
	pass
	
func playSpeedupTheme(): #Doesnt work very well because of yield. Should do the same as with SOUND_DEAD. (Sound dead has trigger, respawn, but speed up not?)
	set_volume_db(4);
	stream = WARNING_THEME;
	play();
	yield(self,"finished");
	playMusic();
	pass
	
func stopMegaShroomTheme(player):
	if(player.is_local_player):
		stream = null;
	pass
	
func getLocalPlayerAmount():
	var localPlayerAmount = 0;
	for pl in Global.player_instances:
		if(pl.is_local_player):
			localPlayerAmount += 1;
	deadPlayers = localPlayerAmount;
	pass
