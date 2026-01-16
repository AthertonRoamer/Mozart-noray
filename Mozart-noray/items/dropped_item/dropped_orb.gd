class_name DroppedOrb
extends DroppedItem

var gravity_force : int = 10
var velocity : Vector2 = Vector2.ZERO
var max_speed : int = 300

func grab(grabber : Player) -> void:
	super(grabber)
	grabber.set_has_orb(true)
	
	
func _process(delta) -> void:
	GameState.world.global_orb_position = global_position
	if position.y > GameState.world.death_altitude:
		GameState.world.pedestal_manager.randomly_set_orb()
		vanish()
	if on_floor():
		velocity.y = 0
	else:
		velocity.y += gravity_force
	if abs(velocity.length()) > max_speed:
		velocity = velocity.normalized() * max_speed
	position += velocity * delta


func on_floor() -> bool:
	return not $FloorDetector.get_overlapping_bodies().is_empty()
	
		
