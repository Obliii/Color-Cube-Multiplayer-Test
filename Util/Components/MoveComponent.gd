class_name MoveComponent
extends Node

# Dependencies
@export var player_character: CharacterBody2D
@export var synced_position := Vector2()
@export var speed := 25.0

func _ready():
	player_character.position = synced_position
	if str(name).is_valid_int():
		get_node("PlayerControllerComponent/InputsSync").set_multiplayer_authority(str(name).to_int())

func update():
	var movement = Input.get_vector("move_left","move_right","move_up","move_down").normalized()
	player_character.velocity = movement * speed
	player_character.move_and_slide()
