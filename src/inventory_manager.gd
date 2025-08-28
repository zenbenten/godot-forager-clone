# src/inventory_manager.gd
extends Node

var inventory = {} # item_id: quantity

func _ready():
	# connect to the global event bus
	GameEvents.connect("resource_gathered", _on_resource_gathered)

func _on_resource_gathered(item_id, quantity):
	print("InventoryManager: Received %s of %s." % [quantity, item_id])
	# TODO: add actual inventory logic here
