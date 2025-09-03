extends Control

# get a reference to the Label node in the scene.
@onready var inventory_label: Label = $InventoryLabel


func _ready():
	# xonnect update_display function to the manager's signal
	InventoryManager.inventory_changed.connect(update_display)
	
	# Call it once at the start to show the initial inventory
	update_display()


# runs every time the inventory changes
func update_display():
	var inventory_text = "Inventory:\n"
	var items = InventoryManager.items

	#loop through every item in the manager's dictionary
	for item_data in items:
		var quantity = items[item_data]
		#add a line to our string for each item
		inventory_text += "- " + item_data.display_name + ": " + str(quantity) + "\n"

	#set the labels text to our final formatted string
	inventory_label.text = inventory_text
