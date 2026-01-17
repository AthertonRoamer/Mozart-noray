class_name Rope
extends Node2D

@export var rope_anchor_scene : PackedScene = preload("res://player/rope/rope_anchor.tscn")

var static_anchor_count : int = 0:
	set(v):
		static_anchor_count = v
		#print("new static anchor count: ", v)

func create_shot_rope(player : Player, direction : Vector2, speed : float) -> RopeAnchor:
	var shot_end : RopeAnchor = rope_anchor_scene.instantiate()
	shot_end.mode_id = RopeAnchor.AnchorModes.FREE
	shot_end.position = player.position
	shot_end.free_anchor.seeking_hold = true
	shot_end.free_anchor.velocity = direction * speed
	
	var held_end : RopeAnchor = rope_anchor_scene.instantiate()
	held_end.mode_id = RopeAnchor.AnchorModes.DYNAMIC
	held_end.position = player.position
	held_end = held_end as RopeAnchor
	
	shot_end.anchor_below = held_end
	held_end.anchor_above = shot_end
	
	add_child(shot_end)
	add_child(held_end)
	
	return held_end
	
	
func _process(_delta):
	for child in get_children():
		if child.mode_id == RopeAnchor.AnchorModes.FREE:
			if is_instance_valid(child.anchor_below) and is_instance_valid(child.anchor_above) and not child.free_anchor.seeking_hold:
				remove_anchor_from_rope(child)
				break
				
				
func remove_anchor_from_rope(child : RopeAnchor) -> void:
	child.anchor_above.length += child.length
	child.anchor_below.anchor_above = child.anchor_above
	child.anchor_above.anchor_below = child.anchor_below
	child.queue_free()
