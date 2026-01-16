class_name World
extends Node2D

var player_scene : PackedScene = preload("res://player/player.tscn")
var fireball_scene : PackedScene = preload("res://player/fireball.tscn")
var dropped_orb_scene : PackedScene = preload("res://items/dropped_item/dropped_orb.tscn")

@export var win_display : WinDisplay
@export var dead_player_ui : DeadPlayerUI
@export var pedestal_manager : PedestalManager
@export var rope_manager : Node2D

var door_position : Vector2 
var global_orb_position : Vector2 = Vector2.ZERO
var death_altitude : int

func _ready():
	GameState.world = self
	GameState.loading_complete.connect(_on_loading_complete)
	death_altitude = int($DeathAltitude.position.y)
	#spawn players
	for id in GameState.players_info:
		spawn_player(id) #adds player as child of players
	get_tree().paused = true
	GameState.submit_client_loaded()
	door_position = $Door.position
	
	
func spawn_player(id : int) -> void:
	var p : Player = player_scene.instantiate()
	var info = GameState.players_info[id]
	p.display_name = info.name
	p.position = $SpawnLocations.get_node(str(info.number)).position
	p.id = id
	p.death_altitude = death_altitude
	get_node("Players").add_child(p)
	
	
func activate_players() -> void:
	for child in $Players.get_children():
		if child.is_in_group("player"):
			child.active = child.local
			
			
func activate_player_by_id(id : int) -> void:
	for child in $Players.get_children():
		if child.is_in_group("player") and child.id == id:
			child.active = child.local
	
	
func _on_loading_complete() -> void:
	activate_players()
	get_tree().paused = false


func handle_orb_died(player : Player) -> void:
	var o = dropped_orb_scene.instantiate()
	o.position = player.position
	$DroppedItems.add_child(o)

 
func set_fireball(caster_id : int, pos : Vector2, direction : Vector2):
	var f := fireball_scene.instantiate()
	f.caster_id = caster_id
	f.position = pos
	f.direction = direction
	add_child(f)


func execute_win(player : Player) -> void:
	win_display.message = " won!"
	win_display.set_display_name(player.display_name)
	win_display.set_display_visible(true)
	get_tree().paused = true
	
	
func handle_everyone_dead() -> void:
	if GameState.solo:
		win_display.message = "You have died"
		win_display.set_display_name("")
		win_display.set_display_visible(true)
		#get_tree().paused = true
	else:
		execute_complete_failure()
	
	
func execute_complete_failure() -> void:
	return
	#win_display.message = "Everyone has died"
	#win_display.set_display_name("")
	#win_display.set_display_visible(true)
	#get_tree().paused = true
