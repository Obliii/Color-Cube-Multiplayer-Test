class_name ColorPreset
extends ColorRect

# signal moment
signal color_selected(color: Color)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		color_selected.emit(color)
