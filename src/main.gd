extends Node2D

@onready var GridController = $Grid
@onready var CannonController = $LaserGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	$Background.modulate = Palletes.BACKGROUND_COLOR


func _process(_delta):
	receive_input()


func receive_input():
	if Input.is_action_just_pressed("activate"):
		GridController.activate(CannonController.horizontal_pos, 
				CannonController.vertical_pos)
		CannonController.activate()
