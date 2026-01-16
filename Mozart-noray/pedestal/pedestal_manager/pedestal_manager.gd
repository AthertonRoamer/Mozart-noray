class_name PedestalManager
extends Node2D

var pedestals : Array[Pedestal] = []


func _ready():
	register_pedestals()
	GameState.loading_complete.connect(_on_loading_complete)
	
	
func _on_loading_complete() -> void:
	randomly_set_orb()
	
	
func randomly_set_orb() -> void:
	if Network.is_server:
		var pedestal_count : int = pedestals.size()
		var r : int = randi_range(0, pedestal_count - 1)
		spawn_orb_at_pedestal.rpc(r)
	
	
@rpc("call_local")
func spawn_orb_at_pedestal(n : int) -> void:
	pedestals[n].spawn_orb()
	
	
func register_pedestals() -> void:
	for c in get_children():
		if c.is_in_group("pedestal"):
			pedestals.append(c)
			c.manager = self
			
			
func erase_pedestal(p : Pedestal) -> void:
	if pedestals.has(p):
		pedestals.erase(p)


