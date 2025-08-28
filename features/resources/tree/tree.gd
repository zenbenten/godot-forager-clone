# features/resources/tree/tree.gd
extends StaticBody2D

#standardized interface for all interactable objects
func interact(interactor):
	print("Tree was chopped down!")
	
	# TODO: replace string "wood" with ItemData resource
	GameEvents.emit_signal("resource_gathered", "wood", 1)
	
	# tree disappears
	queue_free()
