extends Node
class_name GlobalObj

const VERSION_NUMBER = "0.9.4"

const DEBUG_LUIGI_NON_LOCAL = false; #For pseudo-online tests, like sounds that are off-screen
const DEBUG_MODE = false; #faster timer (coop, but unused), bigStar instant spawn, no loading screen, fast win screen, shows Online Menu

var is_online_mode = false;

var player2id = 0;

#mode settings
var playing_splitscreen = false;
var is_vs_mode = true	#false if game is not in vs mode (i.e. coop), unused
var player_amount = 2;
var stars_to_collect = 5;
var wins_to_collect = 3;
var world_selection = true;
var livesWithVS = false; #unused, only in hud so far

var Start_menu_page = 0;

var initialLives = 5;

# Network
var player_amount_local = 0;

#level settings
var current_level_settings_node = null;
var world_to_load = "res://World.tscn";
var level_spawns_mega_shroom = true;
var level_boundary_rect = Rect2(Vector2(0,0),Vector2(9000,280));
var level_infinite_horizontal_scroll = false;
var level_infinite_vertical_scroll = false;
var world_spacing_position = Vector2(0,0);
var world_spacing_end = Vector2(0,0);
var current_tileMap_palette = 0;

#player settings

var players = []

var splitscreen_current_player_hud = 1;
var max_coins = 8;

var player_1_wins = 0;
var player_2_wins = 0;
var player_3_wins = 0;
var player_4_wins = 0;
var match_star_count = [0, 0, 0, 0];

var winnerName = "";

var player_current_stars = [0,0,0,0];
var current_max_stars = 0;

var playerLives = [4, 5, 4, 6];

var playerPositions = [null,null,null,null];
var player_instances = [];

var	deadByTimeUp = false;

#sound (Can be found in Screen -> setSoundChannels())
const MUSIC_BUS_VOLUME = -10;
const SFX_BUS_VOLUME = -11;
var musicC1_path = "";
var sfxStar_path = ""; #Star Collect Sounds
var sfxC0_path = ""; #all yet unbout sounds (Default) 
var sfxC1_path = ""; #Block Break Sound
var sfxC2_path = ""; #Shells ricochet Sound (BUMP)
var sfxC3_path = ""; #Opening of a Block with Items in it (In Item Base Class)
var sfxC4_path = ""; #"other" enemy sounds (Not working????)


#coop
var world_name = 'I-J'
var music_coop_initiated = false;




#Options
var modern_movement = true;
var musicEnabled = true;
var player2LeftRight = true;
var player3BigScreen = true;
var inappropriate_mode = false;
var threeDMode = false;

#Dev Options
var decimalStarCounter = false;
var infinite_vertical_all_levels = false;

#etc
var canvas3DPaths = [];
var spawns_path = "";
#var canPauseGame = true;


func get_player_by_id(id):
	for player in players:
		if (player.playerID == id):
			return player
	return null;
	pass
