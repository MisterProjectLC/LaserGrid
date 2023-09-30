extends Node2D
class_name Main

@onready var GridController = $Grid
@onready var CannonController = $LaserGrid
@onready var Background = $Background

@export var TIME_TO_DETONATE = 6.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Background.modulate = Palletes.BACKGROUND_COLOR
	GridController.start_wave()


func _process(_delta):
	receive_input()


func receive_input():
	if Input.is_action_just_pressed("activate"):
		GridController.activate(CannonController.horizontal_pos, 
				CannonController.vertical_pos)
		CannonController.activate()


func _on_grid_wave_advanced(wave):
	$WaveCounter.text = "Wave " + str(wave)


func explain(text):
	$Explainer.text = text


func _on_grid_failure():
	var tween = create_tween()
	tween.tween_property(Background, 'modulate', Palletes.BACKGROUND_COLOR, 
			0.5).from(Palletes.DAMAGE_BACKGROUND_COLOR)


func _on_grid_success():
	var tween = create_tween()
	tween.tween_property($WaveCounter, 'modulate', Color.WHITE, 
			0.75).from(Palletes.SUCCESS_BACKGROUND_COLOR)
