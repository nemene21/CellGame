extends Polygon2D
class_name ExplodingSprite

@export var shard_script: Script

@export var gravity : float = 600
@export var velocity : float = 800
@export var velocity_randomness := .5
@export var shards := 16
@export var direction := Vector2.ZERO
@export var spread := 66

func start() -> void:
	var texture_size = texture.get_size()
	for i in len(polygon):
		polygon[i] *= texture_size
		
	texture_offset = -.5 * texture_size
	
	explode()

func explode() -> void:
	randomize()
	var texture_size = texture.get_size()
	var points = polygon
	
	for i in (shards - 2):
		points.append(Vector2((randf() - .5) * texture_size.x, (randf() - .5) * texture_size.y))
	
	var triangle_points : PackedInt32Array = Geometry2D.triangulate_delaunay(points)
	for triangle_index in len(triangle_points) / 3.0:
		
		var triangle : Array[Vector2] = [
			points[triangle_points[triangle_index * 3]],
			points[triangle_points[triangle_index * 3 + 1]],
			points[triangle_points[triangle_index * 3 + 2]]
		]
		
		var new_polygon = Polygon2D.new()
		new_polygon.polygon = triangle
		add_child(new_polygon)
		
		new_polygon.texture = texture
		new_polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		new_polygon.texture_offset = -.5 * texture_size
		
		new_polygon.set_script(shard_script)
		new_polygon.set_process(true)
		
		if direction == Vector2.ZERO:
			new_polygon.set("velocity", Vector2(1.0 - randf() * velocity_randomness, 0) * velocity)
			new_polygon.set("velocity", new_polygon.get("velocity").rotated(randf() * PI * 2))
		else:
			var angle : float = randf_range(-spread * .5, spread * .5)
			angle = deg_to_rad(angle)
			new_polygon.set("velocity", direction.rotated(angle) * velocity * (1.0 - randf() * velocity_randomness))
			
		new_polygon.set("rotation_velocity", (randf() - .5) * 8 * PI)
		new_polygon.set("gravity", gravity)
	
	color.a = 0
