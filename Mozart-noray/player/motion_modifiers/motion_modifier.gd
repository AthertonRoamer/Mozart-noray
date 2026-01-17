class_name MotionModifier
extends RefCounted


var authority : int = 1

var active : bool = true:
	set(b):
		if b != active:
			active = b
			on_active_changed(active)
		
		
func on_active_changed(_active : bool) -> void:
	pass
	
	
func modify_motion(v : Vector2) -> Vector2:
	return v
	
	
func attach_to_node(_n : Node2D) -> void:
	pass
	
	
func detach_from_node(_n : Node2D) -> void:
	pass
