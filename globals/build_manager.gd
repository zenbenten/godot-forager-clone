extends Node

#this will hold the data of the object trying to build on the client
var pending_build_data: BuildingData = null
var building_spawner: MultiplayerSpawner = null
var buildings_container: Node = null
var players_container: Node = null # To find player nodes more easily

#this is a temporary variable for the server to use
var _next_build_position: Vector2 = Vector2.ZERO

var building_registry = {}

func _ready():
	#path to all BuildingData .tres files
	var building_data_folder = "res://features/crafting/stations/station_data/"
	
	for file_name in DirAccess.get_files_at(building_data_folder):
		if file_name.ends_with(".tres"):
			var resource = load(building_data_folder + file_name)
			# only load BuildingData resources
			if resource is BuildingData:
				var building_id = file_name.get_basename()
				building_registry[building_id] = resource
				print("Loaded building data: ", building_id)

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
	var player_node = players_container.get_node_or_null(str(p_id))
	if not is_instance_valid(player_node):
		return
	for ingredient: ItemData in p_build_data.ingredients.keys():
		var required = p_build_data.ingredients[ingredient]
		inventory[ingredient] -= required
		if inventory[ingredient] <= 0:
			inventory.erase(ingredient)
		player_node.remove_item_from_inventory.rpc_id(p_id, ingredient.resource_path, required)
		
		
func register_building_spawner(spawner_node: MultiplayerSpawner):
	building_spawner = spawner_node
	#now that we have the reference can connect the signal
	if is_instance_valid(building_spawner):
		building_spawner.spawned.connect(_on_building_spawned)
	else:
		print("BUILD MANAGER ERROR: Invalid spawner registered.")

func register_buildings_container(container_node: Node):
	buildings_container = container_node

func register_players_container(container_node: Node):
	players_container = container_node
