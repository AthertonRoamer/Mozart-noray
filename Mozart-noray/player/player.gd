class_name Player
extends CharacterBody2D

@export var active := false:
	set(b):
		active = b
		$Camera2D.enabled = active

@export var local := false
@export var just_work := false
@export var ghost : bool = false:
	set(b):
		ghost = b
		can_fall = !ghost
		collision_shape.disabled = ghost
		
@export var collision_shape : CollisionShape2D
@export var rope_shooter : RopeShooter

var sword : Sword
var fireball_caster : FireballCaster
var animation_player : AnimationPlayer
@export var health_display : HealthDisplay

@export_group("Sound")
@export var jump_sound : AudioStream
@export var hit_sound : AudioStream

var id : int
var display_name : String = "Player"

var gravity := 25
var jump_speed := 550
var used_double_jump := false
var has_rope_jump : bool = false

var walk_accel : int = 40
var walk_max_speed : int = 300

var air_friction : float = 1
var ground_friction : float = 25

var direction : int
enum direction_options {RIGHT, LEFT}

var walking : bool = false

var motion_modifiers : Array[MotionModifier] = []

var ghost_speed : int = 250

var can_jump : bool = true
var can_walk : bool = true
var can_fall : bool = true

var death_altitude := 2000
var fire_offset = Vector2(18, 0)

var has_orb := false

var health := 100

func _ready():
	name = str(id)
	if multiplayer.get_unique_id() == id:
		local = true
	$Arrow.visible = local
	if just_work:
		active = true
		local = true
	$Camera2D.enabled = active
	set_multiplayer_authority(id)
	set_direction(direction_options.RIGHT)
	
	multiplayer.server_disconnected.connect(disconnected_to_server)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	
	sword = $Sword
	fireball_caster = $FireballCaster
	fireball_caster.caster_id = id
	
	health_display.max_health = health
	health_display.update_health_bar()
	health_display.set_health(health)
	
	animation_player = $AnimationPlayer
	sword.animation_player = animation_player
	animation_player.play("idle")
	
	$DisplayName.text = display_name
	
	
func _physics_process(_delta):
	if has_orb:
		GameState.world.global_orb_position = global_position
	if position.y > death_altitude:
		safe_die()
		
	#apply gravity
	var on_floor = is_on_floor()
	if !on_floor:
		if can_fall:
			velocity.y += gravity
	else:
		velocity.y = 0
		used_double_jump = false
	
	
	if active and not ghost:
		var right : bool = Input.is_action_pressed("player_right")
		var left : bool = Input.is_action_pressed("player_left")
		var jump : bool = Input.is_action_just_pressed("player_jump")
		#var rope_jump : bool = Input.is_action_just_pressed("player_jump_and_release")
		var strike : bool = Input.is_action_just_pressed("player_sword")
		var fire : bool = Input.is_action_just_pressed("player_fire")
		var grab : bool = Input.is_action_just_pressed("player_grab")
		
		if strike and not sword.swinging:
			sword.start_swing()
			
		if fire:
			fireball_caster.fire()
			
		if grab:
			grab_objects.rpc()
		
		if left and can_walk:
			if velocity.x > -walk_max_speed:
				velocity.x -= walk_accel
			if direction != direction_options.LEFT:
				set_direction.rpc(direction_options.LEFT)
		if right and can_walk:
			if velocity.x < walk_max_speed:
				velocity.x += walk_accel
			if direction != direction_options.RIGHT:
				set_direction.rpc(direction_options.RIGHT)
				
		#apply friction
		var effective_friction : float
		if on_floor:
			effective_friction = ground_friction
		else:
			effective_friction = air_friction
			
		var vx = abs(velocity.x)
		vx -= effective_friction
		if vx < 0:
			vx = 0
		velocity.x = vx * sign(velocity.x)
	
		#apply jump
		var already_jumped_this_loop : bool = false
		if jump and can_jump:
			if on_floor:
				velocity.y = -jump_speed
				AudioManager.play(jump_sound)
				already_jumped_this_loop = true
			elif !used_double_jump:
				velocity.y = -jump_speed
				AudioManager.play(jump_sound)
				used_double_jump = true
				already_jumped_this_loop = true
		if has_rope_jump:
			if not already_jumped_this_loop:
				velocity.y = -jump_speed
				AudioManager.play(jump_sound)
			has_rope_jump = false
		
		#apply motion modifiers
		for m in motion_modifiers:
			velocity = m.modify_motion(velocity)
	
	if ghost:
		velocity = Vector2.ZERO
		if Input.is_action_pressed("player_right"):
			velocity += Vector2.RIGHT
		if Input.is_action_pressed("player_left"):
			velocity += Vector2.LEFT
		if Input.is_action_pressed("player_up"):
			velocity += Vector2.UP
		if Input.is_action_pressed("player_down"):
			velocity += Vector2.DOWN
			
		velocity = velocity.normalized() * ghost_speed
	
	move_and_slide()
	
	if local and active:
		sync_position.rpc(position)
		
	#handle animation
	
	if not sword.swinging:
		if not on_floor:
			animation_player.play("idle")
		else:
			if walking:
				if animation_player.current_animation != "walk":
					animation_player.play("walk", -1, 0.8)
			else:
				animation_player.play("idle", -1, 0.5)
				
	walking = velocity.length() > 0
		
		
func add_motion_modifier(m : MotionModifier) -> void:
	m.attach_to_node(self)
	motion_modifiers.append(m)
	
	
func remove_motion_modifier(m : MotionModifier) -> void:
	if motion_modifiers.has(m):
		m.detach_from_node(self)
		motion_modifiers.erase(m)
	
	
func take_damage(dmg : int):
	AudioManager.play(hit_sound)
	health -= dmg
	health_display.set_health(health)
	if health <= 0:
		health = 0
		safe_die()
		
		
@rpc("call_local", "reliable")
func die(): #add code to make sure that if the authority dies, all the shadows die
	print("Player " + display_name + " has perished")
	if has_orb:
		GameState.world.handle_orb_died(self)
	GameState.kill_player(id)
	if local:
		GameState.world.dead_player_ui.active = true
		GameState.world.dead_player_ui.player_id = id
	queue_free()
	
	
func safe_die():
	if active:
		die.rpc()
		active = false
		

func open_door() -> void:
	print(display_name + " is opening door")
	GameState.world.execute_win(self)
		

@rpc("call_local", "reliable")
func grab_objects() -> void:
	for object in $ObjectDetector.get_overlapping_bodies():
		if object.is_in_group("grabbable"):
			object.grab(self)
	for object in $ObjectDetector.get_overlapping_areas():
		if object.is_in_group("grabbable"):
			object.grab(self)


@rpc("call_local")
func set_direction(d : int):
	if direction != d:
		sword.scale.x *= -1
		sword.rotation_degrees *= -1
		fireball_caster.position *= -1
		$Orb.position.x *= -1
	direction = d
	if direction == direction_options.RIGHT:
		$Sprite2D.flip_h = false
		$Orb.flip_h = false
		if is_instance_valid(sword):
			sword.position = Vector2(30, -30)
	else:
		$Sprite2D.flip_h = true
		$Orb.flip_h = true
		if is_instance_valid(sword):
			sword.position = Vector2(-30, -30)
		
		
func set_has_orb(b : bool):
	has_orb = b
	$Orb.visible = b
	#if local:
		#$Arrow.visible = not b
	
	
@rpc
func sync_position(p : Vector2):
	position = p
	
	
func disconnected_to_server():
	active = false
	
	
func on_peer_disconnected(peer_id : int):
	if peer_id == id:
		die()
