extends Node

@export var amount := 0
@export var turnsNeeded := 0

@onready var parent: Cell = get_parent()
@onready var game: Game = parent.get_parent()
@onready var turnsLeft := turnsNeeded

func _ready() -> void:
	parent.restTurn.connect(advance_regen)

func regen() -> void:
	game.add_mana(parent.global_position, amount)
	game.wait(0.05)

func advance_regen() -> void:
	turnsLeft -= 1
	if turnsLeft == 0:
		turnsLeft = turnsNeeded
		regen()
