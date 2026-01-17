extends Node2D

@export var rope_manager : Node2D

func _ready() -> void:
	GameState.world = self
	
	
func set_fireball(_caster_id : int, _pos : Vector2, _direction : Vector2):
	pass
	
	
func handle_everyone_dead() -> void:
	pass
