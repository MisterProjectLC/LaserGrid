extends Node2D
class_name GridControl

enum WAVE_TYPES {SINGLE, DOUBLE, TRIPLE, BLOCKER, DOUBLEBLOCKER, DOUBLETARGET_BLOCKER, FORTIFIED}

var wave_count = 0
var targets_alive = 0

const ROW_COUNT = 4
const COLUMN_COUNT = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	prepare_squares()


func prepare_squares():
	for x in range(ROW_COUNT):
		for y in range(COLUMN_COUNT):
			prepare_square(x, y)

func prepare_square(x, y):
	var square : GridNode = get_square(x, y)
	if x > 0:
		square.neighbor_left = get_square(x-1, y)
	if y > 0:
		square.neighbor_up = get_square(x, y-1)
	if x < ROW_COUNT-1:
		square.neighbor_right = get_square(x+1, y)
	if y < COLUMN_COUNT-1:
		square.neighbor_down = get_square(x, y+1)
	
	square.setup_neighbors()
	square.target_neutralized.connect(on_target_neutralized)
	square.detonated.connect(on_target_detonated)
	


func activate(x, y):
	get_square(x, 0).activate_from_up()
	get_square(0, y).activate_from_left()


func start_wave():
	for x in range(ROW_COUNT):
		for y in range(COLUMN_COUNT):
			var square = get_square(x, y)
			square.set_blocked(false)
			square.set_targeted(false)
	start_specific_wave(WAVE_TYPES.BLOCKER)


func start_specific_wave(wave_type):
	match (wave_type):
		WAVE_TYPES.SINGLE:
			spawn_target()
		WAVE_TYPES.DOUBLE:
			spawn_target()
			spawn_target()
		WAVE_TYPES.TRIPLE:
			spawn_target()
			spawn_target()
			spawn_target()
		WAVE_TYPES.BLOCKER:
			spawn_target()
			spawn_blocker()
		WAVE_TYPES.DOUBLEBLOCKER:
			spawn_centered_target()
			spawn_blocker()
			spawn_blocker()
		WAVE_TYPES.DOUBLETARGET_BLOCKER:
			spawn_centered_target()
			spawn_centered_target()
			spawn_blocker()

func spawn_target():
	targets_alive += 1
	while true:
		var rand_x = (randi() % 4)
		var rand_y = (randi() % 4)
		var square = get_square(rand_x, rand_y)
		if square.is_tagged():
			continue
		square.set_targeted(true)
		return square

func spawn_blocker():
	while true:
		var rand_x = (randi() % 4)
		var rand_y = (randi() % 4)
		var square = get_square(rand_x, rand_y)
		if square.is_tagged():
			continue
		square.set_blocked(true)
		return square

func spawn_centered_target():
	targets_alive += 1
	while true:
		var rand_x = 1 + (randi() % 2)
		var rand_y = 1 + (randi() % 2)
		var square = get_square(rand_x, rand_y)
		if square.is_tagged():
			continue
		square.set_targeted(true)
		return square


func on_target_neutralized(node : GridNode):
	targets_alive -= 1
	if targets_alive <= 0:
		start_wave()

func on_target_detonated(node : GridNode):
	EnergyManager.take_damage()
	start_wave()


# HELPERS ------------------

func get_square(row, column):
	return get_child(column).get_child(row)
