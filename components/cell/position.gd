extends Node
class_name PosComp

@export var position: Vector2i
@onready var parent := get_parent()
@onready var game: Game = parent.get_parent()

func _ready() -> void:
	parent.global_position = position * Global.CELLSIZE + 0.5 * Global.CELLSIZE * Vector2.ONE
	if parent.is_multiplayer_authority():
		update_pos.rpc(position)

func _process(delta: float) -> void:
	parent.global_position = Global.dlerp(
		parent.global_position,
		position * Global.CELLSIZE + 0.5 * Global.CELLSIZE * Vector2.ONE,
		20 * delta
	)

@rpc("call_remote", "reliable")
func update_pos(new_pos: Vector2i) -> void:
	new_pos = Global.mirror_board_x(new_pos)
	game.remove_cell(position)
	position = new_pos
	game.register_cell(new_pos, parent)
