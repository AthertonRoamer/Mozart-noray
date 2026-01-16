extends Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if get_parent().has_orb:
		rotation = global_position.angle_to_point(GameState.world.door_position) + PI / 2
	else:
		rotation = global_position.angle_to_point(get_orb_pos()) + PI / 2
	
	
func get_orb_pos() -> Vector2:
	return GameState.world.global_orb_position
