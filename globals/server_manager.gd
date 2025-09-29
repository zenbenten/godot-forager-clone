extends Node
#everyone's inventories
var player_inventories: Dictionary = {}

#called by the network scripts when a new player connects
func register_player(player_id: int):
	if not multiplayer.is_server():
		return
	print("SERVER MANAGER: Registering new player: ", player_id)
	player_inventories[player_id] = {}

#called by the network scripts when a player disconnects
func unregister_player(player_id: int):
	if not multiplayer.is_server():
		return
	print("SERVER MANAGER: Unregistering player: ", player_id)
	if player_inventories.has(player_id):
		player_inventories.erase(player_id)
		
func server_give_item_to_player(player_id: int, item_resource: ItemData, quantity: int):
	# update the servers authoritative inventory
	var server_inventory = player_inventories[player_id]
	if server_inventory.has(item_resource):
		server_inventory[item_resource] += quantity
	else:
		server_inventory[item_resource] = quantity
		
	#fnd the player node and tell their client to update its UI
	var player_node = get_tree().get_root().get_node_or_null("Game/Players/" + str(player_id))
	if player_node:
		player_node.add_item_to_inventory.rpc_id(player_id, item_resource.resource_path, quantity)
	else:
		print("SERVER ERROR: Could not find player node with ID ", player_id)
