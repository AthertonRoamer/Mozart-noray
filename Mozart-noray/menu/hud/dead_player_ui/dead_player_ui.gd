class_name DeadPlayerUI
extends Control

var player_id : int
var active : bool = false:
	set(b):
		visible = b
		
		
func _ready():
	active = false


func _on_respawn_button_pressed():
	active = false
	PlayerRespawner.request_queue_respawn(player_id)
	GameState.world.win_display.set_display_visible(false)
