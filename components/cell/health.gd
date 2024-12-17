extends Node
class_name HpComp

@export var maxHp := 0
@export var dieParticleColor: Color
@onready var hp := maxHp
@onready var parent: Cell = get_parent()
@onready var game: Game = parent.get_parent()
@onready var posComp: PosComp = parent.get_node("Position")
var dead: bool = false

signal died(cell: Cell)

func _ready() -> void:
	parent.deathTurn.connect(deathcheck)

@rpc("any_peer", "call_local", "reliable")
func die() -> void:
	if dead: return
	dead = true
	
	died.emit(parent)
	game.remove_cell(posComp.position)
	parent.queue_free()
	game.wait(0.075)
	
	AudioManager.play_sound("cell_die", 0.33, 0.4, 0.2, 0.2)
	Vfx.explode_sprite(parent.get_node("Sprite2D"), 2000, 0, Vector2.ZERO, 6)
	game.camera.shake(8, 0.15)
	
	for i in 3:
		var splat = Vfx.play_vfx("splat", parent.global_position, 0, Vector2.ONE, 20)
		splat.modulate *= dieParticleColor

@rpc("any_peer", "call_local", "reliable")
func hurt(dmg: int) -> void:
	hp -= dmg
	AudioManager.play_sound("cell_hit", 1, 1, 0.3, 0.2)
	parent.get_node("AnimationPlayer").play("hit")
	
	var number: Label = Vfx.play_vfx("popup_number", parent.global_position)
	number.text = "-" + str(dmg)
	number.modulate = Color("#a22633")

func deathcheck() -> bool:
	if dead: return true
	# Cell went out of bounds
	if posComp.position.x < 0 or posComp.position.x >= Global.WORLDSIZE.x:
		die.rpc()
		game.hit_player(parent.friendly())
		return true
	
	if hp <= 0:
		die.rpc()
		return true
	# Cell has survived this turn
	return false
