extends Node

var multiplayer_scene = preload("res://scenes/player/multiplayer_player.tscn")
var multiplayer_peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()
var _players_spawn_node
var _hosted_lobby_id = 0

const LOBBY_NAME = "BAD"
const LOBBY_MODE = "CoOP"

func  _ready():
	multiplayer_peer.lobby_created.connect(_on_lobby_created)

func become_host():
	print("HOST: Attempting to become host...")
	multiplayer.peer_connected.connect(_on_peer_connected) 
	multiplayer.peer_disconnected.connect(_on_peer_disconnected) 
	
	multiplayer_peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, SteamManager.lobby_max_members)
	
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)

	if not OS.has_feature("dedicated_server"):
		_add_player_to_game(1)
	
func join_as_client(lobby_id):
	print("CLIENT: Attempting to join as client...")
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	multiplayer_peer.connect_lobby(lobby_id)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)

func _on_lobby_created(lobby_connect: int, lobby_id):
	print("On lobby created")
	if lobby_connect == 1:
		_hosted_lobby_id = lobby_id
		print("Created lobby: %s" % _hosted_lobby_id)
		
		Steam.setLobbyJoinable(_hosted_lobby_id, true)
		
		Steam.setLobbyData(_hosted_lobby_id, "name", LOBBY_NAME)
		Steam.setLobbyData(_hosted_lobby_id, "mode", LOBBY_MODE)

func list_lobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("name", "BAD", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()

func _add_player_to_game(id: int):
	if not multiplayer.is_server():
		return

	print("SERVER: Player %s joined, spawning instance." % id)
	
	#give them server side inventory
	ServerManager.register_player(id)
	
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add, true)
	
func _del_player(id: int):
	print("Player %s left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()

func _on_peer_connected(id):
	print("Event: Peer connected with ID: ", id)

func _on_peer_disconnected(id):
	print("Event: Peer disconnected with ID: ", id)

func _on_connected_to_server():
	print("Event: Successfully connected to server!")

func _on_connection_failed():
	print("Event: Connection failed.")

func _on_server_disconnected():
	print("Event: Disconnected from server.")












	
