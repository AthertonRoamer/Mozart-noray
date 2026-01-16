class_name RopeShooter
extends Ability

#class for shooting and grabbing ropes

@export var rope_scene : PackedScene = preload("res://player/rope/rope.tscn")
@export var shoot_sound : AudioStream

var rope_speed : float = 4000
var attached_anchor : RopeAnchor

var grabbable_anchor_lengths : Array[RopeAnchor] = []

#@onready var test_anchor = $"/root/RopeTestWorld/Ropes/Rope/RopeAnchor2"

func _input(event) -> void:
	if is_instance_valid(player) and player.active:
		if InputMap.event_is_action(event, "player_fire_rope"):
			if Input.is_action_just_pressed("player_fire_rope"):
				if not attached_to_anchor():
					shoot_rope()
			if Input.is_action_just_released("player_fire_rope"):
				pass

		elif InputMap.event_is_action(event, "player_grab_rope"):
			if Input.is_action_just_pressed("player_grab_rope"):
				handle_player_grab_rope.rpc()

		elif InputMap.event_is_action(event, "player_jump_and_release"):
			if Input.is_action_just_pressed("player_jump_and_release"):
				handle_player_jump_and_release.rpc()
					
		elif InputMap.event_is_action(event, "player_drop_hook") and false:
			if Input.is_action_just_pressed("player_drop_hook"):
				print("here")
				handle_player_drop_hook.rpc()


@rpc("call_local", "reliable")
func handle_player_drop_hook() -> void:
	if attached_to_anchor():
		get_last_anchor(attached_anchor).free_anchor.seeking_hold = true
		drop_anchor(attached_anchor)


@rpc("call_local", "reliable")
func handle_player_jump_and_release() -> void:
	if attached_to_anchor(): 
		if attached_anchor.rope.static_anchor_count > 0:
			player.has_rope_jump = true
		drop_anchor(attached_anchor)
	

@rpc("call_local", "reliable")
func handle_player_grab_rope() -> void:
	if attached_to_anchor():
		drop_anchor(attached_anchor)
	elif can_grab_rope():
		grab_anchor(get_anchor_to_grab())
	#else:
		#grab_anchor(test_anchor)
	
	
func can_grab_rope() -> bool:
	return not grabbable_anchor_lengths.is_empty()
	
	
func log_grabbable_anchor_length(anchor : RopeAnchor) -> void:
	if not grabbable_anchor_lengths.has(anchor):
		grabbable_anchor_lengths.append(anchor)
	
	
func unlog_grabbable_anchor_length(anchor : RopeAnchor) -> void:
	if grabbable_anchor_lengths.has(anchor):
		grabbable_anchor_lengths.erase(anchor)
	
	
func get_anchor_to_grab() -> RopeAnchor:
	return grabbable_anchor_lengths[0].create_anchor_for_player(player)
	
	
func grab_anchor(anchor : RopeAnchor) -> void:
	anchor.attach_to_body(player)
	attached_anchor = anchor
	
	
func drop_anchor(anchor : RopeAnchor) -> void:
	anchor.detach_from_body(player)
	attached_anchor = null
	
	
func attached_to_anchor() -> bool:
	return is_instance_valid(attached_anchor)


func shoot_rope() -> void:
	var rope_direction = player.global_position.direction_to(get_global_mouse_position())
	spawn_rope.rpc(rope_direction, rope_speed)
	
	

@rpc("call_local", "reliable")
func spawn_rope(rope_direction : Vector2, r_speed : float) -> void:
	AudioManager.play(shoot_sound)
	var rope : Rope = rope_scene.instantiate()
	rope = (rope as Rope)
	var r : RopeAnchor = rope.create_shot_rope(player, rope_direction, r_speed)
	GameState.world.rope_manager.add_child(rope)
	grab_anchor(r)
	
	
func get_last_anchor(a : RopeAnchor) -> RopeAnchor:
	var going_on : bool = true
	var current_anchor : RopeAnchor = a
	while(going_on):
		if not is_instance_valid(current_anchor.anchor_below):
			going_on = false
		else:
			current_anchor = current_anchor.anchor_below
	return current_anchor
	

func _exit_tree():
	if attached_to_anchor():
		drop_anchor(attached_anchor)


#func _ready() -> void:
	#super()
	#set_multiplayer_authority(player.id)
