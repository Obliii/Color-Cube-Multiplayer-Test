extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 30001
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 20

# Player info for every player as well as the objects associated.
var players = {}
var player_objects = {}

var game_instance: Game

# The idea is to get the name of the player, and the color that they have selected.
var player_info = {"name": "Name", "player_id": 0, "color": Color(1,1,1)}

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	#get_tree().get_root().get_node("ColorSelection").connect("color_selected", _on_color_selected)

func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func create_game(player_name):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	player_info["name"] = player_name
	player_info["player_id"] = multiplayer.get_unique_id()
	players[multiplayer.get_unique_id()] = player_info
	player_connected.emit(multiplayer.get_unique_id(), player_info)
	load_level()

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

# Loads the world up then tries to sync the new player with the state of the world.
@rpc("call_local")
func load_level():
	if game_instance.has_node("level"):
		return
	
	var world = load("res://Maps/level.tscn")
	var world_instance = world.instantiate()
	game_instance.add_child(world_instance)
	var lobby = game_instance.lobby
	if lobby:
		lobby.hide()
	
	if multiplayer.is_server():
		spawn_player(multiplayer.get_unique_id(), player_info)

@rpc("reliable", "any_peer")
func add_player(id, player_data):
	players[id] = player_data
	if multiplayer.is_server():
		spawn_player(id, player_data)
	
	if not multiplayer.is_server():
		spawn_player(id, player_data)

func spawn_player(id, player_data):
	var level = game_instance.get_node_or_null("Level")
	var player_scene = load("res://Objects/objects/playercube.tscn").instantiate()
	player_scene.name = str(id)
	player_scene.set_multiplayer_authority(id)
	game_instance.add_child(player_scene)
	
	player_objects[id] = player_scene

# Register the player to the game and give other players the information.
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	
	if multiplayer.is_server():
		spawn_player(new_player_id, new_player_info)
		
		for existing_id in players:
			if existing_id != new_player_id:
				add_player.rpc_id(new_player_id, existing_id, players[existing_id])

# Player connects and sends the given information to the server.
func _on_player_connected(id, player_name, player_color):
	if multiplayer.is_server():
		var new_player_info = {
			"name": player_name,
			"player_id": id,
			"color": player_color
		}
		_register_player.rpc_id(id, player_info)
	
func _on_player_disconnected(id):
	players.erase(id)
	
	if player_objects.has(id):
		player_objects[id].queue_free()
		player_objects.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players["player_id"] = peer_id
	_register_player.rpc_id(1, player_info)
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	for id in player_objects.keys():
		player_objects[id].queue_free()
	player_objects.clear()
	players.clear()
	server_disconnected.emit()

func _on_color_selected(new_color):
	player_info["color"] = new_color
