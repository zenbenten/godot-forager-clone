extends Node

@rpc("any_peer", "call_local", "reliable")
func server_try_craft_recipe(recipe_path: String):
	var player_id = multiplayer.get_remote_sender_id()
	var recipe: RecipeData = load(recipe_path)
	
	# Check if the servers record shows the player has the ingredients
	var can_craft = check_ingredients(player_id, recipe)
	
	if can_craft:
		print("SERVER: Player ", player_id, " can craft ", recipe.output_item.display_name)
		# first xonsume ingredients from the servers record...
		consume_ingredients(player_id, recipe)
		#...then add the crafted item to the servers record
		add_crafted_item(player_id, recipe)
	else:
		print("SERVER: Player ", player_id, " does not have the ingredients.")

#-----------------------Helper functions for server ----------------------------------
func check_ingredients(p_id, p_recipe: RecipeData) -> bool:
	#returns true if player has enough ingredients for the recipe
	var inventory = ServerManager.player_inventories.get(p_id, {})
	for ingredient: ItemData in p_recipe.ingredients.keys():
		var required = p_recipe.ingredients[ingredient]
		var available = inventory.get(ingredient, 0)
		if available < required:
			return false
	return true

func consume_ingredients(p_id, p_recipe: RecipeData):
	#Removes required items from players inventory and sends RPCs
	var inventory = ServerManager.player_inventories.get(p_id, {})
	for ingredient: ItemData in p_recipe.ingredients.keys():
		var required = p_recipe.ingredients[ingredient]
		if inventory.has(ingredient):
			inventory[ingredient] -= required
			if inventory[ingredient] <= 0:
				inventory.erase(ingredient)
			# tell client about inventory change
			var player_node = get_tree().get_root().get_node("Game/Players").get_node(str(p_id))
			player_node.remove_item_from_inventory.rpc_id(p_id, ingredient.resource_path, required)

func add_crafted_item(p_id, p_recipe: RecipeData):
	# Adds the crafted item to players inventory and sends RPC
	var inventory = ServerManager.player_inventories.get(p_id, {})
	var crafted_item: ItemData = p_recipe.output_item
	var crafted_count = p_recipe.output_quantity
	inventory[crafted_item] = inventory.get(crafted_item, 0) + crafted_count
	#tell client about inventory change
	var player_node = get_tree().get_root().get_node("Game/Players").get_node(str(p_id))
	player_node.add_item_to_inventory.rpc_id(p_id, crafted_item.resource_path, crafted_count)
