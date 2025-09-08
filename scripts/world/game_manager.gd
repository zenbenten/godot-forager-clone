extends Node

func _ready():
	print("Game Manager ready. Please host or join a game.")

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

	for lobby_child in $"../UI/SteamUI/Panel/Lobbies/VBoxContainer".get_children():
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
			fv.set_base_font(load("res://assets/fonts/PixelOperator8.ttf"))
			lobby_button.add_theme_font_override("font", fv)
			lobby_button.set_name("lobby_%s" % lobby) 
			lobby_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			lobby_button.connect("pressed", Callable(self, "join_lobby").bind(lobby))
			
			$"../UI/SteamUI/Panel/Lobbies/VBoxContainer".add_child(lobby_button)
