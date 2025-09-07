# scripts/globals/crafting_manager.gd
extends Node

@rpc("any_peer", "call_local", "reliable")
func server_try_craft_recipe(recipe_path: String):
	var player_id = multiplayer.get_remote_sender_id()
	var recipe: RecipeData = load(recipe_path)
	
	# Check if the server's record shows the player has the ingredients
	var can_craft = check_ingredients(player_id, recipe)
	
	if can_craft:
		print("SERVER: Player ", player_id, " can craft ", recipe.output_item.display_name)
		# 1. Consume ingredients from the server's record
		consume_ingredients(player_id, recipe)
		# 2. Add the crafted item to the server's record
		add_crafted_item(player_id, recipe)
	else:
		print("SERVER: Player ", player_id, " does not have the ingredients.")

# --- Helper functions for the server ---
func check_ingredients(p_id, p_recipe) -> bool:
	# ... Logic to check NetworkManager.player_inventories[p_id] ...
	return true # Placeholder

func consume_ingredients(p_id, p_recipe):
	pass
	# ... Logic to remove items from NetworkManager.player_inventories[p_id] ...
	# ... For each item removed, send an RPC to the client to update their inventory ...
	# get_tree().get_root().get_node("Game/Players").get_node(str(p_id)).remove_item_from_inventory.rpc_id(p_id, ...)

func add_crafted_item(p_id, p_recipe):
	pass
	# ... Logic to add item to NetworkManager.player_inventories[p_id] ...
	# ... Send an RPC to the client to add the new item ...
	# get_tree().get_root().get_node("Game/Players").get_node(str(p_id)).add_item_to_inventory.rpc_id(p_id, ...)
