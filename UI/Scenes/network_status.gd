extends Control
class_name NetworkStatus

@onready var connection_status: Label = $PanelContainer/VBoxContainer/ConnectionStatus
@onready var player_count: Label = $PanelContainer/VBoxContainer/PlayerCount
@onready var server_ip: Label = $PanelContainer/VBoxContainer/ServerIP

# You better have an enum for connectionStatus Network Manager

# Here's where we set up our hook to the network manager
func _ready() -> void:
	# I dunno what that looks like, so we're going to wait
	pass

func update_connection_status(connection_status, players_connected: int, connected_ip: String):
	# if conection_status is disconnected then
	# set connection_status text color to red
	# connection_status.add_theme_color_override("font_color", Color.RED)
	# clear players_connected
	# player_count.text = ""
	# clear server_ip
	# server_ip.text = ""
	
	# else if connection_status is hosting then
	# set connection_status text colour to yellow
	# connection_status.add_theme_color_override("font_color", Color.YELLOW)
	# set connection_status text to hosting as Server
	# connection_status.text = "Hosting as Server"
	# clear players_connected
	# player_count.text = ""
	# clear server_ip
	# server_ip.text = ""
	
	# els
	connection_status.text = "Connected as Client"
	connection_status.add_theme_color_override("font_color", Color.GREEN)
	player_count.text = "Connected players: " + str(players_connected)
	server_ip.text = connected_ip
	pass
