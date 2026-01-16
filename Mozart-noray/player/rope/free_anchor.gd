class_name FreeAnchor
extends AnchorMode

@export var hold_detector : Area2D
@export var hit_sound : AudioStream

var velocity : Vector2 = Vector2.ZERO #Vector2(90, -30)
var gravity : int = 100
var max_speed : int = 1000
var horizontal_friction : float = 1

var seeking_hold : bool = false

var rope_force : Vector2
var rope_force2 : Vector2


func _ready() -> void:
	super()
	#velocity = velocity.normalized() * 700
	
	
func set_active(b : bool) -> void:
	super(b)
	#velocity = Vector2.ZERO


func process_anchor(delta : float) -> void:
	queue_redraw()
	if seeking_hold and hold_available():
		#anchor.position = get_hold_position()
		AudioManager.play(hit_sound)
		anchor.change_mode_by_id(RopeAnchor.AnchorModes.STATIC)
	else:
		#apply gravity
		velocity.y += gravity
		
		#apply horizontal friction
		var v = abs(velocity.x)
		v -= horizontal_friction
		if v < 0:
			v = 0
		velocity.x = v * sign(velocity.x)
		
		#apply max_speed
		#if abs(velocity.length()) > max_speed:
			#velocity = velocity.normalized() * max_speed
		
		rope_force = Vector2.ZERO
		rope_force2 = Vector2.ZERO
		
		#calculate rope force
		if is_instance_valid(anchor.anchor_above) and anchor.position.distance_to(anchor.anchor_above.position) >= anchor.anchor_above.length:
			match anchor.anchor_above.mode_id:
				RopeAnchor.AnchorModes.STATIC:
					set_distance_from_anchor(anchor.anchor_above, anchor.anchor_above.length)
					rope_force = get_rope_force_from_static(anchor.anchor_above, anchor, velocity)
				RopeAnchor.AnchorModes.FREE:
					if anchor.anchor_above.position.y < anchor.position.y:
						set_distance_from_anchor(anchor.anchor_above, anchor.anchor_above.length)
						rope_force = get_rope_force_from_static(anchor.anchor_above, anchor, velocity)
				RopeAnchor.AnchorModes.DYNAMIC:
					if anchor.anchor_above.position.y < anchor.position.y or true:
						set_distance_from_anchor(anchor.anchor_above, anchor.anchor_above.length)
						rope_force = get_rope_force_from_static(anchor.anchor_above, anchor, velocity)
				
		if is_instance_valid(anchor.anchor_below) and anchor.position.distance_to(anchor.anchor_below.position) >= anchor.length:
			match anchor.anchor_below.mode_id:
				RopeAnchor.AnchorModes.STATIC:
					set_distance_from_anchor(anchor.anchor_below, anchor.length)
					rope_force2 = get_rope_force_from_static(anchor.anchor_below, anchor, velocity)
				RopeAnchor.AnchorModes.FREE:
					if anchor.anchor_below.position.y < anchor.position.y:
						set_distance_from_anchor(anchor.anchor_below, anchor.length)
						rope_force2 = get_rope_force_from_static(anchor.anchor_below, anchor, velocity)
				RopeAnchor.AnchorModes.DYNAMIC:
					if anchor.anchor_below.position.y <= anchor.position.y or true:
						set_distance_from_anchor(anchor.anchor_below, anchor.length)
						rope_force2 = get_rope_force_from_static(anchor.anchor_below, anchor, velocity)
					
		velocity += rope_force #add rope force to velocity
		velocity += rope_force2 
				
		anchor.position += velocity * delta
		
		
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
	anchor.position = rope_dir * length + anchor_from.position
		
		
func hold_available() -> bool:
	var holds : Array[Node2D] = hold_detector.get_overlapping_bodies()
	holds = holds.filter(hold_eligible)
	return not holds.is_empty()
	
	
func get_hold_position() -> Vector2:
	return Vector2.ZERO
	
	
func hold_eligible(hold) -> bool:
	return not hold.is_in_group("player")
	
	
func _draw():
	if active:
		var color : Color = Color(0.0, 1.0, 0.0, 1.0)
		var color2 : Color = Color(1.0, 0.0, 0.0, 1.0)
		draw_line(Vector2.ZERO, velocity, color, 10)
		draw_line(Vector2.ZERO, rope_force, color2, 10)
		draw_line(Vector2.ZERO, rope_force2, color2, 10)
		#print(anchor.name + " is drawing velocity")

