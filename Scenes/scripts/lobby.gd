extends Control

const DEFAULT_USER = "Default User"

@onready var ip_address = $Connect/HBoxContainer/IPAddress
@onready var username = $Connect/HBoxContainer/Username
@onready var error_window = $ErrorWindow

func _ready() -> void:
	if OS.has_environment("USERNAME"):
		username.text = OS.get_environment("USERNAME")
	else:
		username.text = DEFAULT_USER
	
func _on_host_button_pressed() -> void:
	if credientials_entered():
		Network.create_game(username.text)

func _on_join_button_pressed() -> void:
	if credientials_entered():
		Network.join_game(ip_address.text)

func show_error_window(message):
	error_window.set_text(message)
	error_window.show()

# Checks if the boxes are not empty.
func credientials_entered():
	if username.text == "":
		show_error_window("Please enter a Username!")
		return false
	
	return true
