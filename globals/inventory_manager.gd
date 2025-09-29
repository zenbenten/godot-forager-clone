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

func remove_item(item_data: ItemData, quantity: int):
	# check if we even have the item
	if items.has(item_data):
		# seduce the quantity
		items[item_data] -= quantity
		
		# If the quantity is zero or less, remove the item from inventory
		if items[item_data] <= 0:
			items.erase(item_data)
			
		#emit the signal so the UI can update
		inventory_changed.emit() 
		
		print("--- Inventory ---")
		for item in items:
			var num = items[item]
			print(item.display_name + ": " + str(num))
		print("-----------------")
	else:
		print("Attempted to remove item not in inventory: ", item_data.display_name)
