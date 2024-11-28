extends Node

@onready var parent: Cell = get_parent()
@onready var animPlayer: AnimationPlayer = parent.get_node("AnimationPlayer")
@export var idleAnimation: String

func _ready() -> void:
	animPlayer.animation_finished.connect(play_idle)

func play_idle(unused: String = "") -> void:
	animPlayer.play(idleAnimation)
	animPlayer.seek(randf())
