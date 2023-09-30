extends Node2D
class_name Main

@onready var GridController = $Grid
@onready var CannonController = $LaserGrid

@export var TIME_TO_DETONATE = 6.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Background.modulate = Palletes.BACKGROUND_COLOR
	GridController.start_wave()


func _process(_delta):
	receive_input()


func receive_input():
	if Input.is_action_just_pressed("activate"):
		GridController.activate(CannonController.horizontal_pos, 
				CannonController.vertical_pos)
		CannonController.activate()


func start_wave():
	GridController.start_wave()
