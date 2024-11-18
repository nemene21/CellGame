extends Node

@export var damage: int
@export var offset: Vector2i
@onready var parent: Cell = get_parent()
@onready var posComp: PosComp = parent.get_node("Position")
@onready var game: Game = parent.get_parent()

func _ready() -> void:
	parent.restTurn.connect(attack)
	if !parent.friendly():
		offset.x *= -1

func attack() -> void:
	var atkPos := posComp.position + offset;
	if !game.cells.has(atkPos):
		return
	
	var attacking: Cell = game.cells[atkPos]
	(attacking.get_node("Health") as HpComp).hurt.rpc(damage)
	game.wait(0.15)
