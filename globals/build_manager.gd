extends Node

#this will hold the data of the object trying to build on the client
var pending_build_data: BuildingData = null

#this is a temporary variable for the server to use
var _next_build_position: Vector2 = Vector2.ZERO

func _ready():
	#the server needs to connect to the spawner signal
	if multiplayer.is_server():
		var spawner = get_tree().get_root().get_node_or_null("Game/BuildingSpawner")
		if is_instance_valid(spawner):
			spawner.spawned.connect(_on_building_spawned)
		else:
			print("BUILD MANAGER ERROR: Could not find MultiplayerSpawner to connect signal.")


# --- client side functions called by UI and player controller) ---

func enter_build_mode(build_data: BuildingData):
	#TODO: add clientside check here for instant feedback if the player can't afford the item

	print("BuildManager: Entering build mode for: ", build_data.building_name)
	pending_build_data = build_data

#needed to cancel build mode, maybe pressing esc?
func exit_build_mode():
	print("BuildManager: Exiting build mode.")
	pending_build_data = null


# --- server side Functions called by rpc ---

#this function is called by the rpc from the player
@rpc("any_peer", "call_local", "reliable")
func server_place_building(building_data_path: String, place_position: Vector2):
	var player_id = multiplayer.get_remote_sender_id()
	print("SERVER: Received build request from player: ", player_id)
	
	var build_data: BuildingData = load(building_data_path)
	var has_ingredients = _check_ingredients(player_id, build_data)
	
	if has_ingredients:
		_consume_ingredients(player_id, build_data)
		
		print("SERVER: Requesting spawner to create '", build_data.building_name, "'...")
		var buildings_container = get_tree().get_root().get_node("Game/Buildings")
		var new_building = build_data.building_scene.instantiate()
		new_building.global_position = place_position
		buildings_container.add_child(new_building)
		# Store the position and tell the spawner to start working
		
	else:
		print("SERVER: Player ", player_id, " does NOT have ingredients. Build failed.")

#this function is called by the spawners "spawned" signal
#(doenst actually work)
func _on_building_spawned(newly_spawned_node):
	print("SERVER: Spawner confirmed a node was created: ", newly_spawned_node.name)
	newly_spawned_node.global_position = _next_build_position
	print("SERVER: Set position of new building to ", newly_spawned_node.global_position)


# --- helper functions ---

func _check_ingredients(p_id: int, p_build_data: BuildingData) -> bool:
	var inventory = ServerManager.player_inventories.get(p_id, {})
	for ingredient: ItemData in p_build_data.ingredients.keys():
		var required = p_build_data.ingredients[ingredient]
		var available = inventory.get(ingredient, 0)
		if available < required:
			return false
	return true

func _consume_ingredients(p_id: int, p_build_data: BuildingData):
	var inventory = ServerManager.player_inventories.get(p_id, {})
	var player_node = get_tree().get_root().get_node_or_null("Game/Players/" + str(p_id))
	if not is_instance_valid(player_node):
		return
	for ingredient: ItemData in p_build_data.ingredients.keys():
		var required = p_build_data.ingredients[ingredient]
		inventory[ingredient] -= required
		if inventory[ingredient] <= 0:
			inventory.erase(ingredient)
		player_node.remove_item_from_inventory.rpc_id(p_id, ingredient.resource_path, required)
