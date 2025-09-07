extends StaticBody2D

@export var drops_item: ItemData
@export var drops_quantity: int = 1

# player calls this
# This function runs on the server
func interact(player_node):
	print(self.name, " was interacted with by: ", player_node.name)
	
	var network_manager = get_node("/root/Game/NetworkManager")
	var player_id = player_node.player_id
	
	# use the ItemData resource as the key
	var server_inventory = network_manager.player_inventories[player_id]
	var item_resource: ItemData = drops_item
	
	if server_inventory.has(item_resource):
		server_inventory[item_resource] += drops_quantity
	else:
		server_inventory[item_resource] = drops_quantity
	
	# tell the client to update its local inventory for the UI
	player_node.add_item_to_inventory.rpc_id(player_id, item_resource.resource_path, drops_quantity)
	
	# tell everyone to destroy this object
	network_manager.destroy_object_rpc.rpc(self.get_path())

@rpc("any_peer")
func add_item_rpc(item_path, quantity):
	# This function would exist on the player or a manager on the client side
	# It would then call the local InventoryManager
	var item_data = load(item_path)
	InventoryManager.add_item(item_data, quantity)
