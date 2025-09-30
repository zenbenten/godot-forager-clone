extends Node

@export var menu_bar_scene: PackedScene
@export var lobby_button_font: Font
var current_menu_bar_instance = null
@onready var spawner = %BuildingSpawner
@onready var buildings_container = %Buildings
@onready var players_container = %Players
@export var ui_canvas: CanvasLayer

func _ready():
	MultiplayerManager.game_manager = self
	print("Game Manager ready. Please host or join a game.")
	
	BuildManager.register_building_spawner(spawner)
	BuildManager.register_buildings_container(buildings_container)
	BuildManager.register_players_container(players_container)
	
	CraftingManager.register_players_container(players_container)

func become_host():
	print("Become host pressed")
	# hide the UI.
	%MultiplayerUI.hide()
	%SteamUI.hide()
	%NetworkManager.become_host()
	
func join_as_client():
	print("Join as player 2")
	join_lobby()

func use_steam():
	print("Using Steam!")
	%MultiplayerUI.hide()
	%SteamUI.show()
	SteamManager.initialize_steam()
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	%NetworkManager.active_network_type = %NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM

func list_steam_lobbies():
	print("List Steam lobbies")
	%NetworkManager.list_lobbies()

func join_lobby(lobby_id = 0):
	print("Joining lobby %s" % lobby_id)
	#hide the UI.
	%MultiplayerUI.hide()
	%SteamUI.hide()
	%NetworkManager.join_as_client(lobby_id)

func _on_lobby_match_list(lobbies: Array):
	print("On lobby match list")
	print("Lobbies found:", lobbies)

	for lobby_child in %LobbyList.get_children():
		lobby_child.queue_free()
		
	for lobby in lobbies:
		var lobby_name: String = Steam.getLobbyData(lobby, "name")
		
		if lobby_name != "":
			var lobby_mode: String = Steam.getLobbyData(lobby, "mode")
			
			var lobby_button: Button = Button.new()
			lobby_button.set_text(lobby_name + " | " + lobby_mode)
			lobby_button.set_size(Vector2(100, 30))
			lobby_button.add_theme_font_size_override("font_size", 8) 
			
			var fv = FontVariation.new()
			fv.set_base_font(lobby_button_font)
			lobby_button.add_theme_font_override("font", fv)
			lobby_button.set_name("lobby_%s" % lobby) 
			lobby_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			lobby_button.connect("pressed", Callable(self, "join_lobby").bind(lobby))
			
			%LobbyList.add_child(lobby_button)
			
#----------------UI------------------------#

func toggle_menu_bar():
	# Check if instance variable points to a existing node.
	if is_instance_valid(current_menu_bar_instance):
		# If it does the menu is open. Close it
		print("GameController: Closing MenuBarUI.")
		current_menu_bar_instance.queue_free()
		current_menu_bar_instance = null #clear the reference
	else:
		# If the variable is null or the instance is invalid the menu is closed. open it
		print("GameController: Opening MenuBarUI.")
		var new_menu_bar = menu_bar_scene.instantiate()
		
		# Store a reference to the new instance immediatly
		current_menu_bar_instance = new_menu_bar
		
		ui_canvas.add_child(current_menu_bar_instance)
