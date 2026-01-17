class_name DynamicAnchor
extends AnchorMode

@export var body : Node2D
var motion_modifier : RopeMotionModifier

var rope_force : Vector2
var rope_force2 : Vector2
var v_from_body : Vector2
var pre_v : Vector2


func _ready() -> void:
	if is_instance_valid(anchor.body):
		attach_to_body(anchor.body)


func attach_to_body(b : Node2D) -> void:
	body = b
	anchor.global_position = body.global_position
	if b.is_in_group("modifiable"):
		motion_modifier = RopeMotionModifier.new()
		motion_modifier.rope_anchor = self
		b.add_motion_modifier(motion_modifier)
		
		
func detach_from_body() -> void:
	body.remove_motion_modifier(motion_modifier)
	body = null
	motion_modifier = null
		
	
func process_anchor(_delta : float) -> void:
	if is_instance_valid(body):
		anchor.position = body.global_position
	
	
func modify_motion(velocity : Vector2) -> Vector2:
	queue_redraw()
	pre_v = velocity
	rope_force = Vector2.ZERO
	rope_force2 = Vector2.ZERO
	#calculate rope force
	if is_instance_valid(anchor.anchor_above) and anchor.position.distance_to(anchor.anchor_above.position) > anchor.anchor_above.length:
		match anchor.anchor_above.mode_id:
			RopeAnchor.AnchorModes.STATIC:
				set_distance_from_anchor(anchor.anchor_above, anchor.anchor_above.length)
				rope_force = get_rope_force_from_static(anchor.anchor_above, anchor, velocity)
			RopeAnchor.AnchorModes.FREE:
				if anchor.anchor_above.position.y < anchor.position.y and false:
					set_distance_from_anchor(anchor.anchor_above, anchor.anchor_above.length)
					rope_force = get_rope_force_from_static(anchor.anchor_above, anchor, velocity)
			RopeAnchor.AnchorModes.DYNAMIC:
				if anchor.anchor_above.position.y < anchor.position.y:
					set_distance_from_anchor(anchor.anchor_above, anchor.anchor_above.length)
					rope_force = get_rope_force_from_static(anchor.anchor_above, anchor, velocity)
			
	if is_instance_valid(anchor.anchor_below) and anchor.position.distance_to(anchor.anchor_below.position) > anchor.length:
		match anchor.anchor_below.mode_id:
			RopeAnchor.AnchorModes.STATIC:
				set_distance_from_anchor(anchor.anchor_below, anchor.length)
				rope_force2 = get_rope_force_from_static(anchor.anchor_below, anchor, velocity)
			RopeAnchor.AnchorModes.FREE:
				if anchor.anchor_below.position.y < anchor.position.y and false:
					set_distance_from_anchor(anchor.anchor_below, anchor.length)
					rope_force2 = get_rope_force_from_static(anchor.anchor_below, anchor, velocity)
			RopeAnchor.AnchorModes.DYNAMIC:
				if anchor.anchor_below.position.y <= anchor.position.y:
					set_distance_from_anchor(anchor.anchor_below, anchor.length)
					rope_force2 = get_rope_force_from_static(anchor.anchor_below, anchor, velocity)
				
	velocity += rope_force #add rope force to velocity
	velocity += rope_force2 
	v_from_body = velocity
	return velocity
	
	
func get_rope_force_from_static(anchor_from : RopeAnchor, anchor_to : RopeAnchor, v : Vector2) -> Vector2:
	var rope_dir : Vector2 = anchor_from.position.direction_to(anchor_to.position) #get direction normal from above anchor to this anchor
	var x_dir : Vector2 = Vector2.RIGHT #get direction normal of x axis
	var a : float = rope_dir.angle_to(x_dir) #get angle between normals
	var rotated_v : Vector2 = v.rotated(a) #rotate velocity by angle
	var rope_force_magnitude = rotated_v.x #get x axis as rope magnitude
	if v.normalized().dot(rope_dir) > 0: #only nullify the force on the rope axis if the force is pointing away from the pivot point. If the force is pointing towards the pivot point, dont nullify if
		return rope_force_magnitude * rope_dir * -1 #apply magnitude to direction
	else:
		return Vector2.ZERO
	
	
func set_distance_from_anchor(anchor_from : RopeAnchor, length : float) -> void:
	var rope_dir : Vector2 = anchor_from.position.direction_to(anchor.position) #get direction normal from above anchor to this anchor
	#pull anchor back so it doesn't go farther than the rope
	if is_instance_valid(body):
		body.position = rope_dir * length + anchor_from.position
	
	
func set_active(b : bool) -> void:
	super(b)
	anchor.image.visible = not b
	
	
func _draw():
	if active:
		var color : Color = Color(0.0, 1.0, 0.0, 1.0)
		var color2 : Color = Color(1.0, 0.0, 0.0, 1.0)
		var color3 : Color = Color.DEEP_PINK
		draw_line(Vector2.ZERO, v_from_body, color, 10)
		draw_line(Vector2.ZERO, pre_v, color3, 5)
		draw_line(Vector2.ZERO, rope_force, color2, 20)
		draw_line(Vector2.ZERO, rope_force2, color2, 20)
	
	
	
