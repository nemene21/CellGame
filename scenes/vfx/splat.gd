extends Sprite2D

var textures := [
	preload("res://scenes/vfx/splat1.png"),
	preload("res://scenes/vfx/splat2.png"),
	preload("res://scenes/vfx/splat3.png"),
	preload("res://scenes/vfx/splat4.png"),
	preload("res://scenes/vfx/splat5.png"),
	preload("res://scenes/vfx/splat6.png")
]

func _ready() -> void:
	rotation = randf_range(-PI, PI)
	position += Vector2(randf_range(-12, 12), randf_range(-12, 12))
	texture = textures.pick_random()
	scale = Vector2.ONE * randf_range(1, 3)
	modulate.a = randf()*0.1 + 0.1


func _on_timer_timeout() -> void:
	$AnimationPlayer.play("die")
