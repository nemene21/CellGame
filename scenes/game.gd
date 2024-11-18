extends Node2D
class_name Game

var playerMana := 35
func update_mana_ui() -> void:
	$UI/Mana.text = str(playerMana) + "/100"

func add_mana(mana: int) -> void:
	playerMana += mana
	update_mana_ui()

var turnWait := .0
func wait(time: float) -> void:
	turnWait += time

var placeable_cells: Dictionary = {
	"testCell": load("res://scenes/cells/worm_cell.tscn")
}

func _ready() -> void:
	Vfx.set_target(self)

func _process(delta: float) -> void:
	queue_redraw()

var cells := {}
func register_cell(pos: Vector2i, cell: Cell) -> bool:
	if cells.has(pos):
		return false
	cells[pos] = cell
	return true

func remove_cell(pos: Vector2i) -> void:
	cells.erase(pos)

@rpc("any_peer", "reliable")
func place_cell(cell_name: String, pos: Vector2i, host_cell: bool, hash_num: int) -> void:
	var cell: Cell = placeable_cells[cell_name].instantiate()
	cell.name = "Cell[" + str(hash_num) + "]"
	
	var posComp: PosComp = cell.get_node("Position")
	posComp.position = pos
	cell.host_team = host_cell
	
	add_child(cell)


func _on_turn_timer_timeout() -> void:
	var cells_arr := get_tree().get_nodes_in_group("cell")
	cells_arr.shuffle()
	
	cells = {}
	for cell: Cell in cells_arr:
		register_cell(cell.get_node("Position").position, cell)
	
	if !Lobby.multiplayer.is_server():
		$TurnTimer.start()
		return
	
	var speedup := 1.0
	for cell: Cell in cells_arr:
		cell.moveTurn.emit()
		if turnWait > 0: await(get_tree().create_timer(turnWait/speedup).timeout)
		turnWait = 0
		speedup += 0.05
	
	cells_arr.shuffle()
	
	speedup = 1.0
	for cell: Cell in cells_arr:
		cell.restTurn.emit()
		if turnWait > 0: await(get_tree().create_timer(turnWait/speedup).timeout)
		turnWait = 0
		speedup += 0.05
	
	cells_arr.shuffle()
	
	speedup = 1.0
	for cell: Cell in cells_arr:
		cell.deathTurn.emit()
		if turnWait > 0: await(get_tree().create_timer(turnWait/speedup).timeout)
		turnWait = 0
		speedup += 0.05
	
	$TurnTimer.start()

func _draw() -> void:
	return
	for pos: Vector2i in cells:
		draw_circle(pos * Global.CELLSIZE + Vector2.ONE * Global.CELLSIZE * 0.5, 10, Color.RED)
