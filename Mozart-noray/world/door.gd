extends StaticBody2D

func grab(grabber : Player) -> void:
	if grabber.has_orb:
		grabber.open_door()
	else:
		print(str(grabber.id) + " cannot open door without orb")
