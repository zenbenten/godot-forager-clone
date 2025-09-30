extends StaticBody2D

@export var drops_item: ItemData
@export var drops_quantity: int = 1

# player calls this
func interact(player_node):
	print(self.name, " was interacted with by: ", player_node.name)
	
	# Tell the manager to handle giving the item to the player
	ServerManager.server_give_item_to_player(player_node.player_id, drops_item, drops_quantity)
	
	# Tell the manager to destroy this object for everyone
	WorldManager.destroy_object_rpc.rpc(self.get_path())
