extends Node2D
class_name Main

@onready var GridController = $Grid
@onready var CannonController = $LaserGrid
@onready var Background = $Background
@onready var WaveResult = %WaveResult
@onready var MusicManager = $MusicManager

@export var TIME_TO_DETONATE = 6.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Background.modulate = Palletes.BACKGROUND_COLOR
	GridController.start_wave()
	%IntroSFX.play()


func _process(_delta):
	receive_input()


func receive_input():
	if Input.is_action_just_pressed("activate"):
		GridController.activate(CannonController.horizontal_pos, 
				CannonController.vertical_pos)
		CannonController.activate()
		%LaserSFX.play()


func _on_grid_wave_advanced(wave):
	$WaveCounter.text = "Wave " + str(wave)
	if wave > 1:
		%AdvanceSFX.play()
	WaveResult.text = "Wave " + str(wave)
	
	match(wave):
		5:
			MusicManager.switch_song(1)
		10:
			MusicManager.switch_song(2)
		40:
			MusicManager.switch_song(3)
		51:
			MusicManager.play_outro()
			WaveResult.text = "Congrats, you made it!"


func explain(text):
	$Explainer.text = text


func _on_grid_failure():
	if EnergyManager.get_health() > 0:
		var tween = create_tween()
		tween.tween_property(Background, 'modulate', Palletes.BACKGROUND_COLOR, 
			0.5).from(Palletes.DAMAGE_BACKGROUND_COLOR)
		%DamageSFX.play()
	else:
		Background.modulate = Palletes.DAMAGE_BACKGROUND_COLOR
		%GameOverSFX.play()
		$Title.game_over()


func _on_grid_success():
	var tween = create_tween()
	tween.tween_property($WaveCounter, 'modulate', Color.WHITE, 
			0.75).from(Palletes.SUCCESS_BACKGROUND_COLOR)


func _on_grid_end():
	$Title.game_over()
