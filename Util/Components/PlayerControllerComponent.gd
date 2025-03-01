class_name PlayerControllerComponent
extends Node

# Dependencies
@export var player_character: CharacterBody2D
@export var move_component: MoveComponent

func _physics_process(delta):
	if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name):
		if move_component:
			move_component.update()
	
	if multiplayer.multiplayer_peer == null or is_multiplayer_authority():
		if move_component and player_character:
			move_component.synced_position = player_character.position
	else:
		if move_component and player_character:
			player_character.position = move_component.synced_position
