extends Node

const CELLSIZE := 96.0
const WORLDSIZE := Vector2i(20, 11)

func mirror_board_x(vec: Vector2) -> Vector2:
	return Vector2(Global.WORLDSIZE.x - vec.x - 1, vec.y)

func dlerp(a: Variant, b: Variant, c: Variant) -> Variant:
	return lerp(b, a, pow(0.5, c))

func get_files(path: String) -> Array[String]:
	var dir = DirAccess.open(path)
	
	var filenames: Array[String] = []

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		filenames.append(file_name)
		file_name = dir.get_next()
		
	return filenames

func remove_file_ending(filename: String) -> String:
	var dot = filename.find(".")
	return filename.left(dot)

var time := .0
func _process(delta) -> void:
	time += delta
