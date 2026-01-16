extends Button

#func _process(delta) -> void:
	#if disabled:
		#print("desabled")
		
		
func _on_pressed():
	GameState.leave_game()
	print("here")
