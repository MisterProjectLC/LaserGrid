extends Sprite2D
class_name Laser

const TIME_TO_FADE_IN = 0.05
const TIME_TO_FADE_OUT = 0.2

func activate():
	var tween = get_tree().create_tween().set_parallel(false)
	tween.tween_method(set_alpha, 0.0, 1.0, TIME_TO_FADE_IN)
	tween.tween_method(set_alpha, 1.0, 0.0, TIME_TO_FADE_OUT)


func set_alpha(a):
	modulate.a = a
