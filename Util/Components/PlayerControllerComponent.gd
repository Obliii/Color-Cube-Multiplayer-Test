class_name PlayerControllerComponent
extends Node

# Dependencies
@export var player_character: CharacterBody2D
@export var camera: Camera2D

# Components
@export var move_component: MoveComponent

func _enter_tree():
	player_character.set_multiplayer_authority(player_character.name.to_int())
	if is_multiplayer_authority():
		#camera.enabled = true
		pass

func _process(_delta):
	if move_component:
		move_component.update()
