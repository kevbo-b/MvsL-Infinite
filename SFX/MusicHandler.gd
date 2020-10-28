extends AudioStreamPlayer

const MEGASHROOM_THEME = preload("res://SFX/NSMB/nsmb_MegaShroom.ogg");
const STAR_THEME = preload("res://SFX/MusicThemes/smb_invincible.ogg");
const WARNING_THEME = preload("res://SFX/8bitSMB/smb_warning.wav");

var isEnabled = true;

var changeSpeed = true;
var isHectic = false;
var customFastTheme = false; #True when no fast theme avaiable. Then gets fasten up with Bus

var deadPlayers = Global.player_amount;

var vs_hectic_players = 0;

var songPath = "res://SFX/MusicThemes/";
var choosenSongFile = null;
var hurryExtension = "";
var fileExtension = ".ogg";

func _ready():
	isEnabled = Global.musicEnabled;
	chooseRandomVSSong();
	pass

func playMusic(hecticCheck = true):
	if(isEnabled && choosenSongFile != null):
		#var a = AudioStreamSample.new();
		#a.set_data =;
		stream = load(songPath + choosenSongFile + hurryExtension + fileExtension);
		if("vs_theme_8bit" in choosenSongFile):
			set_volume_db(-1);
		elif("vs_nsmb_theme_2" in choosenSongFile):
			set_volume_db(6);
		elif("vs_nsmb_theme_1" in choosenSongFile):
			set_volume_db(5);
		else:
			set_volume_db(7);
		play();
		if(isHectic && hecticCheck):
			speedUp();
	pass
	
func stopMusic():
	stop();
	pass
	
func speedUp():
	if(changeSpeed && choosenSongFile != null):
		if(!isHectic && !Global.is_vs_mode):
			set_volume_db(4);
			stream = WARNING_THEME;
			play();
			yield(self,"finished");
			playMusic(false);
			#TimeAlmostUp sound with yield
		
		if(customFastTheme):
			bus = "MusicFast";
			#print(stream.get_mix_rate());
			#stream.set_mix_rate(1.3 * stream.get_mix_rate());
			pitch_scale = 1.3;
		else:
			if(hurryExtension == ""): #so it doesnt reset when song is already fast
				hurryExtension = "_hurry";
				playMusic(false);
		
		isHectic = true;
	pass
	
func normalizeSpeed():
	if(changeSpeed && choosenSongFile != null):
		if(customFastTheme):
			bus = "Music";
			pitch_scale = 1.0;
		else:
			hurryExtension = "";
			playMusic(false);
	
		isHectic = false;
	pass
	
func chooseRandomVSSong():
	customFastTheme = true;
	
	var songs = [];
	songs += ["vs_nsmb_theme_1"];
	songs += ["vs_nsmb_theme_2"];
	songs += ["vs_theme_8bit"];
	
	randomize();
	var number = randi()%songs.size();
	
	choosenSongFile = songs[number];
	pass
	
func setSong(fileName):

	if(fileName == null):
		choosenSongFile = null;
	else:
		if(fileName[0] == "vs_random"):
			chooseRandomVSSong();
		else:
			choosenSongFile = fileName[0];
			
		customFastTheme = fileName[2];
		
		if(!fileName[1]):
			choosenSongFile = fileName[0];
			changeSpeed = false;
	pass
	
func playerRespawned():
	deadPlayers -= 1;
	if(deadPlayers == 0):
		playMusic();
	pass
	
func playerDied():
	deadPlayers += 1;
	stopMusic();
	pass
	
func playMegaShroomTheme():
	stream = MEGASHROOM_THEME;
	set_volume_db(10);
	play();
	pass
	
func stopMegaShroomTheme():
	stream = null;
	pass
