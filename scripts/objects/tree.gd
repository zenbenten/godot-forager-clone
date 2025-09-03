extends StaticBody2D

@export var drops_item: ItemData
@export var drops_quantity: int = 1

# player calls this
func interact(player_node):
	print("Tree was interacted with by: ", player_node.name)
	
	# tell the global manager to add item
	InventoryManager.add_item(drops_item, drops_quantity)
	
	#tree disappears
	queue_free()
