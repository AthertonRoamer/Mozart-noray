class_name DroppedItem
extends Area2D

@export var stats : DroppedItemStats = preload("res://items/dropped_item/dropped_orb.tres")
@export var sprite : Sprite2D
@export var sound : AudioStream = preload("res://sound/pop.wav")


func _ready() -> void:
	sprite.scale = Vector2(3, 3)
	sprite.texture = stats.image
	add_to_group("grabbable")
	collision_layer = 2
	collision_mask = 2
	
	
func grab(_grabber : Player) -> void:
	AudioManager.play(sound)
	vanish()
	
	
func vanish() -> void:
	queue_free()
