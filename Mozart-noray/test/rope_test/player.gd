extends CharacterBody2D

var active : bool = true

var walk_speed := 250
var gravity := 25
var jump_speed := 550

var used_double_jump : bool = false

func _physics_process(_delta):
	var right : bool = Input.is_action_pressed("player_right")
	var left : bool = Input.is_action_pressed("player_left")
	var jump : bool = Input.is_action_just_pressed("player_jump")
	var strike : bool = Input.is_action_just_pressed("player_sword")
	var fire : bool = Input.is_action_just_pressed("player_fire")
	var grab : bool = Input.is_action_just_pressed("player_grab")
	
	var on_floor = is_on_floor()
	
	velocity.x = 0
	if left and active:
		velocity.x -= walk_speed
	if right and active:
		velocity.x += walk_speed
	
	if !on_floor:
		velocity.y += gravity
	else:
		velocity.y = 0
		used_double_jump = false
		
	if jump and active:
		if on_floor:
			velocity.y -= jump_speed
		elif !used_double_jump:
			velocity.y = -jump_speed
			used_double_jump = true
			
	move_and_slide()
