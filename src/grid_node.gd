extends Node2D
class_name GridNode

enum {LEFT, UP, RIGHT, DOWN}

@export var reflect_down = true
@export var reflect_right = true
@export var neighbor_left : GridNode
@export var neighbor_up : GridNode
@export var neighbor_right : GridNode
@export var neighbor_down : GridNode

@onready var lasers = [$LaserLeft, $LaserUp, $LaserRight, $LaserDown]
@onready var neighbors = [neighbor_left, neighbor_up, neighbor_right, neighbor_down]

var reflecting = false

@onready var Background = $Background


func _ready():
	$Sprite2D.modulate = Palletes.GRID_COLOR


func setup_neigbors():
	neighbors = [neighbor_left, neighbor_up, neighbor_right, neighbor_down]


func set_blocked(blocked):
	Background.visible = blocked
	Background.modulate = Palletes.GRID_BLOCKED_COLOR


func set_reflecting(_reflecting):
	reflecting = _reflecting
	Background.visible = _reflecting
	if reflecting:
		Background.modulate = Palletes.GRID_DEFLECT_COLOR


func activate_from_left():
	activate_from_directions(LEFT, reflect_down, DOWN, UP, RIGHT)

func activate_from_up():
	activate_from_directions(UP, reflect_right, RIGHT, LEFT, DOWN)

func activate_from_right():
	activate_from_directions(RIGHT, reflect_down, DOWN, UP, LEFT)

func activate_from_down():
	activate_from_directions(DOWN, reflect_right, RIGHT, LEFT, UP)


func activate_from_directions(original_dir, reflected_bool, reflected_dir_true, 
		reflected_dir_false, non_reflected_dir):
	lasers[original_dir].activate()
	if reflecting:
		if reflected_bool:
			send_laser(reflected_dir_true)
		else:
			send_laser(reflected_dir_false)
	else:
		send_laser(non_reflected_dir)


func send_laser(direction):
	lasers[direction].activate()
	activate_neighbor(neighbors[direction])


func activate_neighbor(neighbor):
	if !neighbor:
		return
	match(neighbor):
		neighbor_left:
			neighbor_left.activate_from_right()
		neighbor_up:
			neighbor_up.activate_from_down()
		neighbor_right:
			neighbor_right.activate_from_left()
		neighbor_down:
			neighbor_down.activate_from_up()


func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		set_reflecting(!reflecting)

