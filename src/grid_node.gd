extends Node2D
class_name GridNode

enum {LEFT, UP, RIGHT, DOWN}

signal detonated(node : GridNode)
signal target_neutralized(node : GridNode)

@export var reflect_down = true
@export var reflect_right = true
@export var neighbor_left : GridNode
@export var neighbor_up : GridNode
@export var neighbor_right : GridNode
@export var neighbor_down : GridNode

@onready var lasers = [$LaserLeft, $LaserUp, $LaserRight, $LaserDown]
@onready var neighbors = [neighbor_left, neighbor_up, neighbor_right, neighbor_down]

var hit_this_frame = false
var targeted = false
var blocked = false
var reflecting = false

@onready var Background = $Background
@onready var Target = $Target

var tween = null

const BLINK_COUNT = 6

func _ready():
	$Sprite2D.modulate = Palletes.GRID_COLOR
	Target.modulate = Palletes.GRID_TARGET_COLOR

func setup_neighbors():
	neighbors = [neighbor_left, neighbor_up, neighbor_right, neighbor_down]


func _process(_delta):
	hit_this_frame = false


func set_blocked(_blocked):
	Background.visible = _blocked
	Background.modulate = Palletes.GRID_BLOCKED_COLOR


func set_targeted(_targeted):
	set_reflecting(false)
	targeted = _targeted
	Target.visible = targeted
	Background.visible = targeted
	Background.modulate = Palletes.GRID_TARGET_BG_COLOR
	
	if targeted:
		tween = create_tween()
		for i in range(1, BLINK_COUNT+1):
			tween.tween_callback(_set_target_visible.bind(false)).set_delay(Main.TIME_TO_DETONATE/pow(2, i))
			tween.tween_callback(_set_target_visible.bind(true)).set_delay(0.15)
		tween.tween_callback(_detonate)

func _set_target_visible(t):
	Target.visible = t

func _detonate():
	set_targeted(false)
	detonated.emit(self)


func set_reflecting(_reflecting):
	if targeted:
		return
	
	if !_reflecting:
		if reflecting:
			EnergyManager.return_reflector()
	elif !reflecting and !EnergyManager.spend_reflector():
		return
	
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
	
	if !targeted:
		return
	if !hit_this_frame:
		hit_this_frame = true
	else:
		neutralize()

func neutralize():
	if tween:
		tween.kill()
	target_neutralized.emit(self)


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



func _on_target_timer_timeout():
	pass # Replace with function body.
