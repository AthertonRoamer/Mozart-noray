class_name AnchorMode
extends Node2D

@export var anchor : RopeAnchor

var active : bool = false

func _ready() -> void:
	add_to_group("anchor_mode")
	

func process_anchor(_delta : float) -> void:
	pass
	
	
func set_active(b : bool) -> void:
	active = b
