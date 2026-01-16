class_name Pedestal
extends StaticBody2D

var orb_less_texture := preload("res://pedestal/Pedestal.png")
var orb_texture := preload("res://pedestal/Pedestal-with-Orb.png")

@export var grab_sound : AudioStream
@export var has_orb := false
var manager : PedestalManager


func _ready():
	set_has_orb(has_orb)
		
		
func grab(grabber : Player):
	if has_orb:
		set_has_orb(false)
		AudioManager.play(grab_sound)
		grabber.set_has_orb(true)
		
		
func spawn_orb() -> void:
	if not has_orb:
		set_has_orb(true)
		
		
func exit_tree() -> void:
	if is_instance_valid(manager):
		manager.erase_pedestal(self)
		
		
func set_has_orb(b : bool) -> void:
	has_orb = b
	if has_orb:
		$Sprite2D.texture = orb_texture
	else:
		$Sprite2D.texture = orb_less_texture
	$OrbLight.visible = has_orb
	
	
func _process(_delta):
	if has_orb:
		GameState.world.global_orb_position = global_position
		
		

