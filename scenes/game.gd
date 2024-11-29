extends Node2D
class_name Game

var playerMana := 35
func update_mana_ui() -> void:
	$UI/Mana.text = str(playerMana) + "/100"

func add_mana(pos: Vector2, mana: int) -> void:
	playerMana += mana
	update_mana_ui()
	var number: Label = Vfx.play_vfx("popup_number", pos)
	number.text = "+" + str(mana)
	number.modulate = Color("#2ce8f5")

var turnWait := .0
var speedup := .0
func wait(time: float) -> void:
	turnWait += time

var placeable_cells: Dictionary = {
	"WormCell": load("res://scenes/cells/worm_cell.tscn"),
	"SparkCell": load("res://scenes/cells/spark_cell.tscn"),
	"ManaCell": load("res://scenes/cells/mana_cell.tscn")
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
	
	speedup = 1.0
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
