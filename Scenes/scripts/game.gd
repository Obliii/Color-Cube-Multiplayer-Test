class_name Game
extends Node2D

@onready var color_selection: ColorSelectionMenu = $CanvasLayer/ColorSelection
@onready var lobby_ui: Lobby = $CanvasLayer/Lobby
@onready var color_selector_ui = $CanvasLayer/ColorSelection
@onready var network_status_ui = $CanvasLayer/NetworkStatus
var level: Node2D

func _ready() -> void:
	Network.game_instance = self
	color_selection.color_selected.connect(new_color_selected)

func new_color_selected(new_color):
	Network._on_color_selected(new_color)
