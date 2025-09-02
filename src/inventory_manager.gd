extends Node

signal inventory_changed

var items  = {} # key: ItemData, Value: int

# Add a given quantity of an item to the inventory
func add_item(item_data: ItemData, quantity: int):
	if items.has(item_data): #check if we have this item
		items[item_data] += quantity #if yes, increase its quantity
	else:
		items[item_data] = quantity
	
	# For the listening UI to be updated
	inventory_changed.emit()
	
	# Output inventory
	print("--- Inventory ---")
	for item in items:
		var num = items[item]
		print(item.display_name + ": " + str(num))
	print("-----------------")
