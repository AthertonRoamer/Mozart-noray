class_name PlayerRespawnHandler
extends Node

var respawn_queue : Array[int] = []

var in_respawing_process : bool = false
var respawning_id : int
var loaded_peers : Array[int] = []


@rpc("any_peer", "call_local", "reliable")
func queue_respawn(id : int) -> void:
	if Network.is_server:
		print("appending respawn request ", id)
		respawn_queue.append(id)
		
		
		
func request_queue_respawn(id : int) -> void:
	print("requesting respawn for ", id)
	queue_respawn.rpc(id)
	
	
	
func _process(_delta):
	if Network.is_server:
		if not in_respawing_process and not respawn_queue.is_empty():
			print("starting respawn request ", respawning_id)
			start_respawn_process(respawn_queue.pop_front())
		elif in_respawing_process:
			for id in GameState.players_info:
				if not loaded_peers.has(id):
					return
			in_respawing_process = false
			print("sending signal to activate respawned player ", respawning_id)
			activate_respawned_player.rpc(respawning_id)
			
			
func start_respawn_process(id : int) -> void:
	in_respawing_process = true
	loaded_peers = []
	respawning_id = id
	respawn_player.rpc(id)
	
	
@rpc("call_local", "reliable")
func respawn_player(id : int) -> void:
	print("peer ", multiplayer.get_unique_id(), " spawned player ", id)
	GameState.world.spawn_player(id)
	submit_spawn_complete.rpc(multiplayer.get_unique_id())
	
	
	
@rpc("any_peer", "call_local", "reliable")
func submit_spawn_complete(from : int) -> void:
	if Network.is_server:
		print("received submit spawn complete from ", from)
		loaded_peers.append(from)
		print("new loaded peers: ", loaded_peers)
		print("players info: ", GameState.players_info)
		
		
		
		
@rpc("call_local", "reliable")
func activate_respawned_player(id : int) -> void:
	print("activating respawned player ", id)
	GameState.world.activate_player_by_id(id)
	
	
	
	
	
