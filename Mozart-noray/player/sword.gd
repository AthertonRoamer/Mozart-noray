class_name Sword
extends Area2D

@export var sword_sound : AudioStream

var swinging := false
var damage := 15
var already_hit_bodies := []

var animation_player : AnimationPlayer

func _process(_delta):
	if swinging:
		for body in get_overlapping_bodies():
			if body != get_parent() and body.is_in_group("player") and not already_hit_bodies.has(body):
				body.take_damage(damage)
				already_hit_bodies.append(body)
	
	
func start_swing():
	swing.rpc()
	
	
@rpc("call_local", "reliable")
func swing():
	AudioManager.play(sword_sound)
	swinging = true
	if animation_player != null:
		animation_player.play("strike", -1, 2)
	$SwingTimer.start()
	

func _on_swing_timer_timeout():
	swinging = false
	already_hit_bodies = []
	#if animation_player != null:
		#animation_player.play("idle")
