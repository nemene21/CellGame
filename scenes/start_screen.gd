extends Node2D

func _ready() -> void:
	Lobby.playerConnected.connect(set_player_num_ui)
	Lobby.playerDisconnected.connect(set_player_num_ui)
	set_player_num_ui()

func set_player_num_ui(_id: int = 0) -> void:
	$Label.text = "Players in rn: " + str(len(Lobby.players))

func _on_button_pressed() -> void:
	Lobby.start_game.rpc("res://scenes/game.tscn")
