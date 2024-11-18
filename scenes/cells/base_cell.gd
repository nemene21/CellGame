extends Node2D
class_name Cell

signal moveTurn
signal restTurn
signal deathTurn
@export var host_team := true
@onready var game: Game = get_parent()

func friendly() -> bool:
	return host_team == Lobby.multiplayer.is_server()

func _ready() -> void:
	set_multiplayer_authority(1)
	game.register_cell(get_node("Position").position, self)

	if !friendly():
		$Sprite2D.flip_h = true
