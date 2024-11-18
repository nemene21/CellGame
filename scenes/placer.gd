extends Sprite2D

@onready var game: Game = get_parent()

func can_place() -> bool:
	var placePos: Vector2i = floor(get_global_mouse_position() / Global.CELLSIZE)
	if placePos.x < 0 or placePos.x >= Global.WORLDSIZE.x or \
	   placePos.y < 0 or placePos.y >= Global.WORLDSIZE.y:
			return false
	
	return !game.cells.has(placePos)

func attempt_place() -> void:
	if !can_place():
		return
	
	var hash_num := hash(Global.time)
	var placePos: Vector2 = floor(get_global_mouse_position() / Global.CELLSIZE)
	game.place_cell.rpc(
		"testCell", Global.mirror_board_x(placePos), Lobby.multiplayer.is_server(), hash_num
	)
	game.place_cell(
		"testCell", placePos, Lobby.multiplayer.is_server(), hash_num
	)


func _process(delta: float) -> void:
	# Following mouse
	var mousePos := get_global_mouse_position()
	var snapped: Vector2 = floor(mousePos / Global.CELLSIZE) * Global.CELLSIZE
	snapped += Vector2.ONE * 0.5 * Global.CELLSIZE
	
	global_position = Global.dlerp(global_position, snapped, delta * 20)
	
	# Placing
	if Input.is_action_pressed("place"):
		attempt_place()
	
	# Color
	material.set_shader_parameter("tint", lerp(Color.RED, Color("28ff00"), can_place()))
