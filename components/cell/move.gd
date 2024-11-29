extends Node
class_name MoveComp

@export var direction: Vector2i
@onready var parent: Cell = get_parent()
@onready var game: Game = parent.get_parent()

func _ready() -> void:
	parent.moveTurn.connect(move)

func move() -> void:
	var posComp: PosComp = parent.get_node("Position")
	var moveMaking := direction if parent.friendly() else Vector2i(-direction.x, direction.y)
	var newPos: Vector2i = posComp.position + moveMaking
	
	if game.cells.has(newPos):
		return
	
	game.wait(0.075)
	game.remove_cell(posComp.position)
	posComp.position = newPos
	posComp.update_pos.rpc(posComp.position)
	AudioManager.play_sound.rpc("move")
	game.register_cell(newPos, parent)
