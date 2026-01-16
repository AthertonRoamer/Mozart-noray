extends Area2D

var speed := 600
var direction : Vector2
var motion_gravity := 0
var damage := 15

var caster_id : int

func _ready() -> void:
	$AnimationPlayer.play("spawn", -1, 2)


func _process(delta):
	position += speed * delta * direction 
	position.y += motion_gravity * delta
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.id != caster_id:
			body.take_damage(damage)
			vanish()
			
			
func vanish() -> void:
	queue_free()


func _on_vanish_timer_timeout():
	vanish()
