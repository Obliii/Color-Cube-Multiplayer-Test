extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal player_connection_failed
signal server_disconnected

const PORT = 30001
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 20

# Player info for every player as well as the objects associated.
var players = {}
var game_instance: Game

# The idea is to get the name of the player, and the color that they have selected.
var player_info = {"name": "Name", "id": 0}

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_successful)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
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
	multiplayer.peer_connected.connect(spawn_player)
	player_connected.emit(multiplayer.get_unique_id(), player_info)
	reveal_lobby(false)
	load_level()
	spawn_player()

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

# Loads the world up then tries to sync the new player with the state of the world.
@rpc("call_local", "reliable")
func load_level():
	if game_instance.has_node("level"):
		return
	
	var world = load("res://Maps/level.tscn")
	var world_object = world.instantiate()
	game_instance.level = world_object
	game_instance.add_child(world_object)

func spawn_player(id = 1):
	var player_scene = load("res://Objects/playercube.tscn").instantiate()
	var player_list = game_instance.get_node("Players")
	player_scene.name = str(id)
	player_list.call_deferred("add_child", player_scene)

@rpc("any_peer", "call_local")
func despawn_player(id):
	var player_list = game_instance.get_node("Players")
	player_list.get_node(str(id)).queue_free()

# Player connects and sends the given information to the server.
func _on_player_connected(id):
	players[id] = players
	load_level.rpc_id(id)
	_register_player.rpc_id(1, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id):
	rpc("despawn_player", id)
	players.erase(id)
	player_disconnected.emit(id)

# Client: On a successful connection, get the client's unique ID and send it to the server.
func _on_connected_successful():
	reveal_lobby(false)
	var peer_id = multiplayer.get_unique_id()
	players["player_id"] = peer_id
	player_connected.emit(peer_id)

# Client: On a failed connection from client, disconnect multiplayer peer and emit a signal. 
func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	player_connection_failed.emit()

# Client: On disconnection from server, reopen the lobby and reset the game state.
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	reset_game()
	reveal_lobby(true)
	players.clear()
	server_disconnected.emit()

func reveal_lobby(value):
	var lobby = game_instance.lobby
	if lobby and value:
		lobby.show()
	else:
		lobby.hide()

func reset_game():
	for entity in game_instance.get_node("Players").get_children():
		entity.queue_free()
	game_instance.queue_free()

func _on_color_selected(new_color):
	player_info["color"] = new_color
