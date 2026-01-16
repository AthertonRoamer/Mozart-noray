class_name FireballCaster
extends Node2D

@export var fire_sound : AudioStream

var caster_id : int
var loaded : bool = true

func fire():
	if loaded:
		var mouse_pos = get_global_mouse_position()
		var dir = global_position.direction_to(mouse_pos)
		AudioManager.play(fire_sound)
		trigger_set_fireball.rpc(caster_id, global_position, dir)
		loaded = false
		$ReloadTimer.start()
	

@rpc("call_local", "reliable")
func trigger_set_fireball(id : int, pos : Vector2, direction : Vector2):
	GameState.world.set_fireball(id, pos, direction)


func _on_reload_timer_timeout():
	loaded = true
