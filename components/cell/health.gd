extends Node
class_name HpComp

@export var maxHp := 0
@export var dieParticleColor: Color
@onready var hp := maxHp
@onready var parent: Cell = get_parent()
@onready var game: Game = parent.get_parent()
@onready var posComp: PosComp = parent.get_node("Position")

signal died(cell: Cell)

func _ready() -> void:
	parent.deathTurn.connect(deathcheck)

@rpc("any_peer", "call_local", "reliable")
func die() -> void:
	died.emit(parent)
	game.remove_cell(posComp.position)
	parent.queue_free()
	game.wait(0.075)
	
	AudioManager.play_sound("cell_die", 0.33, 0.4, 0.2, 0.2)
	Vfx.explode_sprite(parent.get_node("Sprite2D"), 2000, 0, Vector2.ZERO, 6)

@rpc("any_peer", "call_local", "reliable")
func hurt(dmg: int) -> void:
	hp -= dmg
	AudioManager.play_sound("cell_hit", 1, 1, 0.3, 0.2)
	parent.get_node("AnimationPlayer").play("hit")

func deathcheck() -> bool:
	# Cell went out of bounds
	if posComp.position.x < 0 or posComp.position.x >= Global.WORLDSIZE.x:
		die.rpc()
		return true
	
	if hp <= 0:
		die.rpc()
		return true
	# Cell has survived this turn
	return false
