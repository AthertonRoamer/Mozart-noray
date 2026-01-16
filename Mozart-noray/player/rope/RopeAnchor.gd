class_name RopeAnchor
extends Node2D

@export var max_length : float = 500 #the larget allowed length of rope for when rope lengths are adjustable
@export var length : float = max_length #the current longest length of rope
var real_length : float #the actual current distance between this anchor and anchor_below

@export var rope_color : Color = Color(0.0, 0.0, 0.0, 1.0)
@export var highlight_color : Color = Color(1.0, 1.0, 1.0, 1.0)

@export var rope_anchor_width : float = 30

@export var anchor_above : RopeAnchor = null
@export var anchor_below : RopeAnchor = null

@export var mode_id : AnchorModes = AnchorModes.FREE

@export_group("Internal")

@export var mode : AnchorMode

@export var free_anchor : FreeAnchor
@export var static_anchor : StaticAnchor
@export var dynamic_anchor : DynamicAnchor

@export var body : Node2D
@export var image : Sprite2D

@export var rope_area : Area2D
@export var rope_area_collision_shape : CollisionShape2D

@onready var rope_anchor_scene : PackedScene = get_parent().rope_anchor_scene
@onready var rope : Rope = get_parent()


enum AnchorModes {STATIC, FREE, DYNAMIC}

var grabbable : bool = false

func _ready() -> void:
	register_anchor_modes()
	change_mode_by_id(mode_id)
	rope_area_collision_shape.shape.size.y = rope_anchor_width
	
	
func create_anchor_for_player(player : Player) -> RopeAnchor:
	var r : RopeAnchor = rope_anchor_scene.instantiate()
	r = r as RopeAnchor
	r.mode_id = RopeAnchor.AnchorModes.FREE
	r.global_position = Geometry2D.get_closest_point_to_segment(player.global_position, global_position, anchor_below.global_position)
	#change lengths
	if global_position.y <= anchor_below.global_position.y: #if above or level with anchor below
		var new_length : float = global_position.distance_to(r.global_position)
		r.length = length - new_length
		length = new_length
	else: #if under anchor below
		var new_length : float = anchor_below.global_position.distance_to(r.global_position)
		r.length = new_length
		length -= new_length
	if r.length <= 0:
			print("length was somehow less than 0")
			r.length = 0.01
	#change neighbor anchors
	r.anchor_below = anchor_below
	anchor_below.anchor_above = r
	anchor_below = r
	r.anchor_above = self
	get_parent().add_child(r)
	return r
	
	
func attach_to_body(b : Node2D) -> void:
	change_mode_by_id(AnchorModes.DYNAMIC)
	dynamic_anchor.attach_to_body(b)


func detach_from_body(b : Node2D) -> void:
	if mode_id == AnchorModes.DYNAMIC and dynamic_anchor.body == b:
		dynamic_anchor.detach_from_body()
		free_anchor.velocity = Vector2.ZERO
		change_mode_by_id(AnchorModes.FREE)


func change_mode(m : AnchorMode) -> void:
	if m != mode and m != null:
		if is_instance_valid(mode):
			mode.set_active(false)
		mode = m
		mode.set_active(true)
		
	
func change_mode_by_id(m : AnchorModes) -> void:
	match m:
		AnchorModes.STATIC:
			if mode != static_anchor:
				rope.static_anchor_count += 1
			change_mode(static_anchor)
		AnchorModes.FREE:
			if mode == static_anchor:
				rope.static_anchor_count -= 1
			change_mode(free_anchor)
		AnchorModes.DYNAMIC:
			if mode == static_anchor:
				rope.static_anchor_count -= 1
			change_mode(dynamic_anchor)
	mode_id = m


func _process(delta):
	queue_redraw()
	mode.process_anchor(delta)
	
	
func update_grabbable() -> void:
	for b in rope_area.get_overlapping_bodies():
		if b.is_in_group("player"):
			b = b as Player
			if not b.rope_shooter.attached_to_anchor():
				grabbable = true
				return
	grabbable = false
	
	
func _draw():
	update_area()
	if is_instance_valid(anchor_below):
		update_grabbable()
		if grabbable:
			draw_line(Vector2.ZERO, to_local(anchor_below.global_position), highlight_color, 6.0, true)
		draw_line(Vector2.ZERO, to_local(anchor_below.global_position), rope_color, 3.0, true)
		#draw_line(Vector2.ZERO, to_local(anchor_below.global_position).normalized() * length, Color(0.0, 0.0, 1.0, 1.0), 10)
		
	
func register_anchor_modes() -> void:
	for c in get_children():
		if c.is_in_group("anchor_mode"):
			(c as AnchorMode).anchor = self
			
			
func update_area() -> void:
	if is_instance_valid(anchor_below):
		rope_area_collision_shape.disabled = false
		real_length = global_position.distance_to(anchor_below.global_position)
		rope_area_collision_shape.shape.size.x = real_length + rope_anchor_width
		var rope_dir : Vector2 = global_position.direction_to(anchor_below.global_position)
		rope_area.position = to_local(anchor_below.global_position) / 2
		rope_area.rotation = rope_dir.angle()
	else:
		rope_area_collision_shape.disabled = true
		

func _on_robe_area_body_entered(collision_body):
	if collision_body.is_in_group("player"):
		collision_body = collision_body as Player
		collision_body.rope_shooter.log_grabbable_anchor_length(self)


func _on_robe_area_body_exited(collision_body):
	if collision_body.is_in_group("player"):
		collision_body = collision_body as Player
		collision_body.rope_shooter.unlog_grabbable_anchor_length(self)


func _exit_tree() -> void:
	if mode == static_anchor:
		rope.static_anchor_count -= 1
