extends Sprite2D

var waiting_input = false
var tween = null

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	$AnimationPlayer.play("Intro")
	await title_anim()
	await get_tree().create_timer(1.6).timeout
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	tween.tween_property($Laser, 'position', Vector2(160, -20), 0.8)
	tween.tween_property($Grid, 'position', Vector2(-160, 10), 0.8)


func game_over():
	get_tree().paused = true
	$AnimationPlayer.play_backwards("Intro")
	await get_tree().create_timer(0.5).timeout
	await title_anim()
	await get_tree().create_timer(0.5).timeout
	%WaveResult.visible = true
	await get_tree().create_timer(1.0).timeout
	%Retry.visible = true
	waiting_input = true


func _process(_delta):
	if waiting_input and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		get_tree().reload_current_scene()
		EnergyManager.reset()

func title_anim():
	await get_tree().create_timer(0.5).timeout
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(
			Tween.TRANS_SINE).set_parallel(true)
	tween.tween_property($Laser, 'position', Vector2(0, -20), 0.5).from(Vector2(-160, -20))
	tween.tween_property($Grid, 'position', Vector2(0, 10), 0.5).from(Vector2(160, 10))
	
	await get_tree().create_timer(0.4).timeout
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	tween.tween_property($Laser, 'position', Vector2(20, -20), 2.0)
	tween.tween_property($Grid, 'position', Vector2(-20, 10), 2.0)
	
	return true
