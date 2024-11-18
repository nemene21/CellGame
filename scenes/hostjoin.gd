extends Node2D

func _ready() -> void:
	$Address.text = str(Lobby.get_local_ip())

func _on_host_pressed() -> void:
	Lobby.host($Address.text)
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

func _on_join_pressed() -> void:
	Lobby.join($Address.text)
