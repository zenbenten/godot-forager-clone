extends StaticBody2D

@export var drops_item: ItemData
@export var drops_quantity: int = 1

# player calls this
# This function runs on the server
func interact(player_node):
	print("Rock was interacted with by: ", player_node.name)
	
	# Call the RPC on the specific player node that interacted
	player_node.add_item_to_inventory.rpc_id(player_node.player_id, drops_item.resource_path, drops_quantity)
	
	#the server tells the NetworkManager to destroy this tree for everyone
	var network_manager = get_node("/root/Game/NetworkManager")
	network_manager.destroy_object_rpc.rpc(self.get_path())

@rpc("any_peer")
func add_item_rpc(item_path, quantity):
	# This function would exist on the player or a manager on the client side
	# It would then call the local InventoryManager
	var item_data = load(item_path)
	InventoryManager.add_item(item_data, quantity)
