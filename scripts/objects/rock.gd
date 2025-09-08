extends StaticBody2D

@export var drops_item: ItemData
@export var drops_quantity: int = 1

# player calls this
func interact(player_node):
	print(self.name, " was interacted with by: ", player_node.name)
	
	var network_manager = get_node("/root/Game/NetworkManager")
	
	# Tell the manager to handle giving the item to the player
	network_manager.server_give_item_to_player(player_node.player_id, drops_item, drops_quantity)
	
	# Tell the manager to destroy this object for everyone
	network_manager.destroy_object_rpc.rpc(self.get_path())

@rpc("any_peer")
func add_item_rpc(item_path, quantity):
	# This function would exist on the player or a manager on the client side
	# It would then call the local InventoryManager
	var item_data = load(item_path)
	InventoryManager.add_item(item_data, quantity)
