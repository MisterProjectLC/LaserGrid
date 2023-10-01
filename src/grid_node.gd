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

@export var target_sprite : Texture
@export var quick_sprite : Texture
@export var fortified_sprite : Texture

@onready var lasers = [$LaserLeft, $LaserUp, $LaserRight, $LaserDown]
@onready var neighbors = [neighbor_left, neighbor_up, neighbor_right, neighbor_down]

var hit_this_frame = false
var targeted = false
var blocked = false
var reflecting = false

var fortified = false
var quick = false

var x = 0
var y = 0

@onready var Background = $Background
@onready var Target = $Target
@onready var Direction = $DeflectionDirection

var tween = null

const TIME_TO_DETONATE = 12.0
const QUICK_TIME_TO_DETONATE = 4.0
const BLINK_COUNT = 6

func _ready():
	$Sprite2D.modulate = Palletes.GRID_COLOR
	Target.modulate = Palletes.GRID_TARGET_COLOR
	Direction.modulate = Palletes.GRID_DEFLECT_COLOR
	if !reflect_down and reflect_right:
		Direction.rotation_degrees = 0
	elif reflect_down and reflect_right:
		Direction.rotation_degrees = 90
	elif reflect_down and !reflect_right:
		Direction.rotation_degrees = 180
	elif !reflect_down and !reflect_right:
		Direction.rotation_degrees = 270
	

func setup_neighbors():
	neighbors = [neighbor_left, neighbor_up, neighbor_right, neighbor_down]


func _process(_delta):
	hit_this_frame = false


func set_fortified(f):
	fortified = f
	Target.texture = fortified_sprite if fortified else target_sprite

func set_quick(q):
	quick = q
	Target.texture = quick_sprite if quick else target_sprite


func set_blocked(_blocked):
	blocked = _blocked
	Direction.visible = !blocked
	Background.visible = _blocked
	Background.modulate = Palletes.GRID_BLOCKED_COLOR


func set_targeted(_targeted):
	set_reflecting(false)
	targeted = _targeted
	Direction.visible = !targeted
	
	if !targeted:
		set_fortified(false)
		set_quick(false)
	Target.visible = _targeted
	
	Background.visible = targeted
	Background.modulate = Palletes.GRID_TARGET_BG_COLOR
	
	var time_to_detonate = TIME_TO_DETONATE if !quick else QUICK_TIME_TO_DETONATE
	if targeted:
		if tween: tween.kill()
		tween = create_tween()
		for i in range(1, BLINK_COUNT+1):
			tween.tween_callback(_set_target_visible.bind(false)).set_delay(time_to_detonate/pow(2, i))
			tween.tween_callback(_set_target_visible.bind(true)).set_delay(0.15)
		tween.tween_callback(_detonate)
	elif tween:
		tween.kill()

func _set_target_visible(t):
	Target.visible = t

func _detonate():
	set_targeted(false)
	detonated.emit(self)


func set_reflecting(_reflecting):
	if is_tagged():
		return
	
	if !_reflecting:
		if reflecting:
			EnergyManager.return_reflector()
	elif !reflecting and !EnergyManager.spend_reflector():
		return
	
	reflecting = _reflecting
	Background.visible = _reflecting
	if reflecting:
		Background.modulate = Palletes.GRID_DEFLECT_BG_COLOR


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
	if blocked:
		return
	
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
	if tween: tween.kill()
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
		if reflecting:
			$ToggleSFX.play()
		else:
			$ToggleOutSFX.play()


func is_tagged():
	return targeted or blocked

