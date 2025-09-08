extends Node

enum MULTIPLAYER_NETWORK_TYPE { ENET, STEAM }

@export var _players_spawn_node: Node2D
#everyone's inventories
var player_inventories: Dictionary = {}

var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.ENET
var enet_network_scene := preload("res://scenes/networks/enet_network.tscn")
var steam_network_scene := preload("res://scenes/networks/steam_network.tscn")
var active_network

func _build_multiplayer_network():
	if not active_network:
		print("Setting active_network")
		
		MultiplayerManager.multiplayer_mode_enabled = true
		
		match active_network_type:
			MULTIPLAYER_NETWORK_TYPE.ENET:
				print("Setting network type to ENet")
				_set_active_network(enet_network_scene)
			MULTIPLAYER_NETWORK_TYPE.STEAM:
				print("Setting network type to Steam")
				_set_active_network(steam_network_scene)
			_:
				print("No match for network type!")

func _set_active_network(active_network_scene):
	var network_scene_initialized = active_network_scene.instantiate()
	active_network = network_scene_initialized
	active_network._players_spawn_node = _players_spawn_node
	add_child(active_network)

func become_host(is_dedicated_server = false):
	_build_multiplayer_network()
	MultiplayerManager.host_mode_enabled = true if is_dedicated_server == false else false
	active_network.become_host()
	
func join_as_client(lobby_id = 0):
	_build_multiplayer_network()
	active_network.join_as_client(lobby_id)
	
func list_lobbies():
	_build_multiplayer_network()
	active_network.list_lobbies()




@rpc("any_peer", "call_local", "reliable")
func destroy_object_rpc(object_path: NodePath):
	var object_to_destroy = get_node_or_null(object_path)
	if object_to_destroy:
		print("Destroying object at path: ", object_path)
		object_to_destroy.queue_free()
		
func server_give_item_to_player(player_id: int, item_resource: ItemData, quantity: int):
	# update the servers authoritative inventory
	var server_inventory = player_inventories[player_id]
	if server_inventory.has(item_resource):
		server_inventory[item_resource] += quantity
	else:
		server_inventory[item_resource] = quantity
		
	#fnd the player node and tell their client to update its UI
	var player_node = _players_spawn_node.get_node_or_null(str(player_id))
	if player_node:
		player_node.add_item_to_inventory.rpc_id(player_id, item_resource.resource_path, quantity)
	else:
		print("SERVER ERROR: Could not find player node with ID ", player_id)
