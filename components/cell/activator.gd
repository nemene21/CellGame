extends Node

@onready var parent: Cell = get_parent()
@onready var game: Game = parent.get_parent()
@onready var posComp: PosComp = get_parent().get_node("Position")
@export var offset: Vector2i = Vector2(1, 0)

func _ready() -> void:
	parent.restTurn.connect(activate)

func activate() -> void:
	var targetPos := offset if parent.friendly() else Vector2i(-offset.x, offset.y)
	targetPos += posComp.position
	if !game.cells.has(targetPos):
		return
	var cell: Cell = game.cells[targetPos]
	
	cell.moveTurn.emit()
	if game.turnWait > 0: await(get_tree().create_timer(game.turnWait/game.speedup).timeout)
	game.turnWait = 0
	
	cell.restTurn.emit()
	if game.turnWait > 0: await(get_tree().create_timer(game.turnWait/game.speedup).timeout)
	game.turnWait = 0
