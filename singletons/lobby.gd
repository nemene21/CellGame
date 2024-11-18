extends Node

const PORT: int = 40667
const MAX_CONNECTIONS := 4

signal playerConnected(id)
signal playerDisconnected(id)
signal serverDisconnected

class PlayerInfo:
	var name: String
	func _init(name):
		self.name = name

var players: Dictionary = {}
var playerData: PlayerInfo
var playersConnected := 0

func _ready() -> void:
	multiplayer.peer_connected.connect(_player_connect)
	multiplayer.peer_disconnected.connect(_player_disconnect)
	multiplayer.connected_to_server.connect(_this_player_connect)
	multiplayer.server_disconnected.connect(_server_disconnect)

func get_local_ip() -> String:
	for possible_addr in IP.get_local_addresses():
		if possible_addr.begins_with("192.168."):
			return possible_addr
	return "No viable IP"

@rpc("any_peer", "reliable", "call_local")
func start_game(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func terminate() -> void:
	multiplayer.multiplayer_peer = null

func host(addr=""):
	if addr.is_empty():
		addr = get_local_ip()
	
	var peer := ENetMultiplayerPeer.new()
	var err  := peer.create_server(PORT, MAX_CONNECTIONS)
	if err:
		print("Failed to host, ", err)
		return err
	
	multiplayer.multiplayer_peer = peer
	players[1] = playerData
	playerConnected.emit(1, playerData)
	print("Managed to host")

func join(addr=""):
	if addr.is_empty():
		for possible_addr in IP.get_local_addresses():
			if possible_addr.begins_with("192.168."):
				addr = possible_addr
				break
	
	var peer := ENetMultiplayerPeer.new()
	var err  := peer.create_client(addr, PORT)
	if err:
		print("Failed to join, ", err)
		return err
	
	multiplayer.multiplayer_peer = peer
	print("Managed to join")

@rpc("any_peer", "reliable", "call_local")
func register_player(info: PlayerInfo) -> void:
	var id := multiplayer.get_remote_sender_id()
	print("Registered id ", id)
	players[id] = info
	playerConnected.emit(id)

@rpc("any_peer", "reliable")
func update_player_data(info: PlayerInfo) -> void:
	var id := multiplayer.get_remote_sender_id()
	players[id] = info

func _this_player_connect() -> void:
	register_player.rpc(playerData)
	var id = multiplayer.get_unique_id()
	playerConnected.emit(id)

func _player_connect(id: int) -> void:
	print("Joined id ", id)
	register_player.rpc_id(id, playerData)

func _player_disconnect(id: int) -> void:
	print("Disconnected id ", id)
	players.erase(id)
	playerDisconnected.emit(id)

func _server_disconnect():
	print("Server disconnected")
	terminate()
	players.clear()
	serverDisconnected.emit()
