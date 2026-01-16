class_name Ability
extends Node2D

var player : Player

func _ready() -> void:
	var p : Node = get_parent()
	if p is Player:
		player = p
	else:
		push_error("Ability " + str(name) + " at " + str(get_path()) + " doesnt have a player as a parent")
