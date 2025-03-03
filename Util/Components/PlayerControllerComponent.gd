class_name PlayerControllerComponent
extends Node

# Dependencies
@export var player_character: CharacterBody2D
@export var camera: Camera2D
@export var move_component: MoveComponent

func _enter_tree():
	set_multiplayer_authority(player_character.name.to_int())
	if is_multiplayer_authority():
		#camera.enabled = true
		pass

func _physics_process(_delta):
	if is_multiplayer_authority():
		if move_component:
			move_component.update()
