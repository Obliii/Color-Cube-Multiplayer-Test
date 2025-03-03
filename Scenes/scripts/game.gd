class_name Game
extends Node2D

@onready var color_selection = $CanvasLayer/ColorSelection
@onready var lobby = $CanvasLayer/Lobby
@onready var multiplayer_spawner: MultiplayerSpawner = $PlayerMultiplayerSpawner
var level: Node2D

func _ready() -> void:
	Network.game_instance = self
	color_selection.color_selected.connect(new_color_selected)

func new_color_selected(new_color):
	Network._on_color_selected(new_color)
