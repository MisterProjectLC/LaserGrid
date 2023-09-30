extends Node2D
class_name CannonControl

var horizontal_pos = 0
var vertical_pos = 0

var grid_blockers = []
var grid_mirrors = []

@onready var Horizontal = $Horizontal
@onready var Vertical = $Vertical

@onready var HorizontalCannon = $%HorizontalCannon
@onready var VerticalCannon = $%VerticalCannon

var hor_tween = null
var vert_tween = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	receive_input()


func receive_input():
	if Input.is_action_just_pressed("up"):
		add_to_vertical_pos(-1)
	
	elif Input.is_action_just_pressed("down"):
		add_to_vertical_pos(1)
	
	if Input.is_action_just_pressed("left"):
		add_to_horizontal_pos(-1)
	
	elif Input.is_action_just_pressed("right"):
		add_to_horizontal_pos(1)


func activate():
	VerticalCannon.activate()
	if vert_tween: vert_tween.kill()
	VerticalCannon.global_position = Vertical.get_child(vertical_pos).global_position
	HorizontalCannon.activate()
	if hor_tween: hor_tween.kill()
	HorizontalCannon.global_position = Horizontal.get_child(horizontal_pos).global_position


func add_to_vertical_pos(offset):
	vertical_pos = clamp(vertical_pos+offset, 0, Vertical.get_child_count()-1)
	if vert_tween: vert_tween.kill()
	vert_tween = create_tween()
	vert_tween.tween_property(VerticalCannon, 'global_position', 
		Vertical.get_child(vertical_pos).global_position, 0.1)


func add_to_horizontal_pos(offset):
	horizontal_pos = clamp(horizontal_pos+offset, 0, Horizontal.get_child_count()-1)
	if hor_tween: hor_tween.kill()
	hor_tween = create_tween()
	hor_tween.tween_property(HorizontalCannon, 'global_position', 
		Horizontal.get_child(horizontal_pos).global_position, 0.1)



