extends Node
signal starting_game
signal closing_game
signal loading_complete

var player_name : String = "Player"

var players_info : Dictionary

var players := 0
var loaded_players : int = 0
var winner : int
var solo : bool = false

@export var main_menu_scene := preload("res://menu/main_menu.tscn")
@export var world_scene := preload("res://world/world.tscn")
var world : Node2D
var in_menu : bool = true


func _ready():
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func get_my_player_info() -> Dictionary:
	return {"name" : player_name, "alive" : true}


func add_player(id : int, info : Dictionary) -> void:
	players += 1
	info["number"] = players
	players_info[id] = info
	
	
func remove_player(id : int) -> void:
	var dead_num = players_info[id].number
	players_info.erase(id)
	for i in players_info:
		if players_info[i].number > dead_num:
			players_info[i].number -= 1
	players -= 1
	
	
func kill_player(id : int) -> void:
	if players_info.has(id):
		players_info[id].alive = false
	var one_alive_player : bool = false
	for p in players_info:
		if players_info[p].alive:
			one_alive_player = true
			break
	if not one_alive_player:
		if is_instance_valid(world):
			world.handle_everyone_dead()
	
	
func on_peer_disconnected(peer_id : int) -> void:
	for key in players_info.keys():
		if key == peer_id:
			remove_player(peer_id)
	
	
func trigger_start_game():
	Network.set_server_joinable(false)
	start_game.rpc()
	
	
@rpc("call_local")
func start_game():
	solo = Network.is_server and multiplayer.get_peers().size() == 0
	starting_game.emit()
	get_tree().change_scene_to_packed(world_scene)
	in_menu = false
	
	
@rpc("call_local", "reliable")
func announce_loading_complete() -> void:
	loading_complete.emit()
	print("loaded")
	
	
@rpc("any_peer", "reliable")
func submit_client_loaded() -> void:
	if Network.is_server:
		loaded_players += 1
		if loaded_players == players:
			announce_loading_complete.rpc()
	else:
		submit_client_loaded.rpc_id(1)
	
	
#intended to be called on server to close the game for every peer
func trigger_close_game() -> void:
	#Network.set_server_joinable(true) Cant do this, because the server quits when the game closes
	close_game.rpc()
	

#closes the game on this computer
@rpc("call_local")
func close_game() -> void:
	closing_game.emit()
	exit_to_main_menu()
	
	
#called to exit the game, when its not necessarily done for other peers
func leave_game() -> void:
	if Network.is_server:
		trigger_close_game()
	else:
		close_game()
	
	
func exit_to_main_menu() -> void:
	if not in_menu:
		get_tree().change_scene_to_packed(main_menu_scene)
		print("changing scene to main menu scene")
		in_menu = true
	
	
func _on_server_disconnected() -> void:
	exit_to_main_menu()
	
	
func clear():
	players_info = {}
	players = 0
	loaded_players = 0
