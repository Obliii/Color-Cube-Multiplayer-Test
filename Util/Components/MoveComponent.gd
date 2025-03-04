class_name MoveComponent
extends Node

# Dependencies
@export var player_character: CharacterBody2D
@export var synced_position := Vector2()
@export var speed := 100.0

# Initialize the synced position
func _enter_tree():
	player_character.position = synced_position

# Move the player and update their synced position if they are the player, if they aren't then sync the player for everyone else.
func update():
	if is_multiplayer_authority():
		var movement = Input.get_vector("move_left","move_right","move_up","move_down").normalized()
		player_character.velocity = movement * speed
		player_character.move_and_slide()
		synced_position = player_character.position
	else:
		player_character.position = synced_position
