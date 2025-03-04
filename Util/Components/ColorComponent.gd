class_name ColorComponent
extends Node

@onready var color_rect: ColorRect = $"../ColorRect"
@onready var color_selector = Network.game_instance.color_selector_ui

# Connect to the signals from the Color Selection Menu
func _ready():
	color_selector.connect("color_selected", _change_color)

# Changes the color of the block when a button is pressed from ColorSelectionMenu
func _change_color(new_color):
	color_rect.color = new_color
