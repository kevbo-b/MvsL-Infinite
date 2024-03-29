extends Node

# https://docs.godotengine.org/de/stable/tutorials/networking/high_level_multiplayer.html
# https://www.youtube.com/watch?v=Xu3LtVihYoo

const DEFAULT_PORT = 24819;
const MAX_PLAYERS = 4;
var DEFAULT_IP = '127.0.0.1';

var notifications = []

var players = {}
# Info we send to other players
var self_data = { name = 'null', position = Vector2(0,0), state = 0, favorite_color = Color8(255, 0, 255) }


var chatMessageQueue = {};

var methodConnected = false;


var clientConnected = -1; #disconnected. 1 = connected, 0 = connection failed, < 0 = error


func _ready():
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected") #only works if initiated here
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connected_fail")
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	#get_tree().connect("network_peer_connected", self, "_player_connected") #cant cope with 3 players ?
	pass


func _server_disconnected():
	clientConnected = -2; #server closed
	pass

func create_server(player_nickname):
	self_data.name = player_nickname
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)

func connect_to_server(player_nickname):
	self_data.name = player_nickname
#	if(!methodConnected):
#		get_tree().connect("connected_to_server", self, "_player_connected") #maybe make "network_peer_connected", works for all not just client
#		methodConnected = true
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer);



func _player_disconnected(id): #server data
	notifications.append(str(players[id].name + " left the game."))
	#Global.player_amount = Global.player_amount - 1;
	players.erase(id) # Erase player from info.


func _player_connected(id): #only runs in client. Check for changing from connecting as client to lobby
#get_tree().get_network_unique_id()
	Global.player2id = id;
	players[id] = self_data
	rpc('_send_player_info', get_tree().get_network_unique_id(), self_data) #sends signal so it works not only in client
	clientConnected = 1;
	

func _connected_fail():
	clientConnected = 0;
	pass
	
	
func syncData():
	rpc('refreshClientData', players);
	pass
	
func refreshClientData(pl):
	players = pl;
	pass


remote func _send_player_info(id, info):     #when client is connected, send everyone data
	if get_tree().is_network_server():
		for peer_id in players:
			rpc_id(id, '_send_player_info', peer_id, players[peer_id]);
	players[id] = info
	
	print("Connected! Name: " + str(players[id].name)) #all clients do this lol
	
	
	# add player to game, set player name 


func connectNetworkFunctions():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	pass



func initStartLevel(level):
	for peer_id in players:
		if(peer_id != 1):
			rpc_id(peer_id, 'loadLevel', level[1]);
	loadLevel(level[1]);
	pass

remote func loadLevel(level):
	Global.player_amount_local = 1;
	print("Set to 1")
	
	Global.is_online_mode = true;
	Global.playing_splitscreen = false;
	Global.current_max_stars = 0;
	Global.player_current_stars = [0,0,0,0];
	
	Global.world_to_load = level;
	get_tree().change_scene("Menu/ReadyScreen.tscn");
	pass


func getClientCodeMsg():
	if(clientConnected == 1):
		return "Online"
	if(clientConnected == 0):
		return "Connection Failed"
	if(clientConnected == -1):
		return "Disconnected (Default)"
	if(clientConnected == -2):
		return "Server closed."
	pass
