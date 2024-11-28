extends Label

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()

func _ready() -> void:
	global_position += Vector2(
		randf_range(-16, 16),
		randf_range(-16, 16)
	)
