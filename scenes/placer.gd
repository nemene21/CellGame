extends Sprite2D

@onready var game: Game = get_parent()
var placing := "SparkCell"

var placeBorder := 10
var placeBorderPos = .0
@export var placeBorderSprite: Sprite2D

func update_texture() -> void:
	var instance: Cell = game.placeable_cells[placing].instantiate()
	texture = instance.get_node("Sprite2D").texture
	instance.free()

func _ready() -> void:
	update_texture()

func can_place() -> bool:
	var placePos: Vector2i = floor(get_global_mouse_position() / Global.CELLSIZE)
	if placePos.x < 0 or placePos.x >= Global.WORLDSIZE.x or \
	   placePos.y < 0 or placePos.y >= Global.WORLDSIZE.y:
			return false
	
	if placePos.x >= placeBorder:
		return false
	return !game.cells.has(placePos)

func attempt_place() -> void:
	if !can_place():
		return
	
	var hash_num := hash(Global.time)
	var placePos: Vector2 = floor(get_global_mouse_position() / Global.CELLSIZE)
	game.place_cell.rpc(
		placing, Global.mirror_board_x(placePos), Lobby.multiplayer.is_server(), hash_num
	)
	game.place_cell(
		placing, placePos, Lobby.multiplayer.is_server(), hash_num
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
	
	# Swapping
	for i in 5:
		if Input.is_action_just_pressed("Slot " + str(i+1)):
			placing = ["WormCell", "ManaCell", "SparkCell"][i]
			update_texture()
	
	# Place border
	placeBorderSprite.global_position.x = placeBorderPos
	placeBorderSprite.global_position.y = 540
	
	var wantedPos := placeBorder * Global.CELLSIZE
	placeBorderPos = Global.dlerp(placeBorderPos, wantedPos, 20 * delta)
