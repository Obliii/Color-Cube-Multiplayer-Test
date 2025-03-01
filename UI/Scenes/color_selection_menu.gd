class_name ColorSelectionMenu
extends Control

@onready var blue: ColorPreset = $PanelContainer/VBoxContainer/HFlowContainer/Blue
@onready var green: ColorPreset = $PanelContainer/VBoxContainer/HFlowContainer/Green
@onready var red: ColorPreset = $PanelContainer/VBoxContainer/HFlowContainer/Red

signal color_selected(selected_color: Color)

var clickables: Array[ColorPreset] 

func _ready() -> void:
	clickables = [blue, green, red]
	for rect: ColorPreset in clickables:
		rect.color_selected.connect(_on_color_preset_color_selected)

func _on_color_preset_color_selected(color: Color) -> void:
	color_selected.emit(color)
	print("ColorSelectionMenu says, \"" +color.to_html(false)+ "\"")
