extends Camera2D
class_name ShakeableCam

var shakeStr := .0
var shakeTimer := .0
var shakeTimerMax := 1.0

func reset_shake() -> void:
	shakeStr = .0
	shakeTimer = .0
	shakeTimerMax = 1.0
	
func calc_anim() -> float:
	return ease(shakeTimer / shakeTimerMax, 2.2)

func _process(delta: float) -> void:
	shakeTimer -= delta
	if shakeTimer < 0:
		reset_shake()
	
	offset = calc_anim() * shakeStr * Vector2(randf(), randf())

func shake(strength: float, time: float) -> void:
	shakeStr = strength
	shakeTimer = time
	shakeTimerMax = time
