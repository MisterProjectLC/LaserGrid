extends Node2D
class_name GridControl

signal wave_advanced(wave)
signal explain(text)

enum WAVE_TYPES {SINGLE, DOUBLE, TRIPLE, BLOCKER, DOUBLEBLOCKER, QUICKBLOCKER,
	DOUBLETARGET_BLOCKER, FORTIFIED, TUTORIAL_0, TUTORIAL_1, TUTORIAL_2, TUTORIAL_3}

var wave_count = 0
var targets_alive = 0
var fortified = false
var wave_pool = []

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
	square.x = x
	square.y = y
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
	targets_alive = 0
	for x in range(ROW_COUNT):
		for y in range(COLUMN_COUNT):
			var square = get_square(x, y)
			square.set_blocked(false)
			square.set_targeted(false)
	
	choose_wave()
	
	wave_count += 1
	wave_advanced.emit(wave_count)


func choose_wave():
	if wave_count < 2:
		if wave_count == 1:
			explain.emit("Align both lasers to deactivate cells")
		return start_specific_wave(WAVE_TYPES.TUTORIAL_0)
	
	if wave_count < 5:
		if wave_count == 2:
			explain.emit("WASD to move the cannons")
		return start_specific_wave(WAVE_TYPES.SINGLE)
	
	if wave_count < 10:
		if wave_count == 5:
			explain.emit("Blue cells deflect lasers")
			return start_specific_wave(WAVE_TYPES.TUTORIAL_1)
		elif wave_count == 6:
			return start_specific_wave(WAVE_TYPES.TUTORIAL_2)
		elif wave_count == 7:
			return start_specific_wave(WAVE_TYPES.TUTORIAL_3)
		explain.emit("Click on cells to toggle deflect")
		return start_specific_wave(WAVE_TYPES.BLOCKER)
	
	if wave_count == 31:
		return start_specific_wave(WAVE_TYPES.FORTIFIED)
	
	if wave_count >= 30 and wave_count % 10 == 0:
		if wave_count == 30:
			explain.emit("Destroy them with one burst!")
		return start_specific_wave(WAVE_TYPES.FORTIFIED)
	
	if wave_count >= 10 and (wave_count+3) % 5 == 0:
		return start_specific_wave(WAVE_TYPES.DOUBLETARGET_BLOCKER)
	
	if wave_count >= 10 and wave_count % 5 == 0:
		return start_specific_wave(WAVE_TYPES.DOUBLEBLOCKER)
	
	if wave_count % 2 == 0:
		if wave_count == 14:
			explain.emit("Destroy them quickly!")
		if wave_count <= 20:
			return start_specific_wave(WAVE_TYPES.DOUBLE) 
		else:
			return start_specific_wave(WAVE_TYPES.TRIPLE) 
	
	if wave_count <= 30:
		return start_specific_wave(WAVE_TYPES.BLOCKER) 
	else:
		return start_specific_wave(WAVE_TYPES.QUICKBLOCKER) 
	

func start_specific_wave(wave_type):
	fortified = false
	match (wave_type):
		WAVE_TYPES.SINGLE:
			spawn_random_target()
		WAVE_TYPES.DOUBLE:
			spawn_random_target(true)
			spawn_random_target(true)
		WAVE_TYPES.TRIPLE:
			spawn_random_target()
			spawn_random_target(true)
			spawn_random_target(true)
		WAVE_TYPES.BLOCKER:
			var target = spawn_random_target()
			spawn_hard_blocker(target)
		WAVE_TYPES.QUICKBLOCKER:
			var target = spawn_random_target(true)
			spawn_hard_blocker(target)
		WAVE_TYPES.DOUBLEBLOCKER:
			var target = spawn_centered_target()
			spawn_hard_blocker(target)
			spawn_blocker()
		WAVE_TYPES.DOUBLETARGET_BLOCKER:
			var target = spawn_random_target()
			spawn_random_target()
			spawn_hard_blocker(target)
		WAVE_TYPES.FORTIFIED:
			fortified = true
			spawn_centered_target(false, true)
			spawn_random_target(false, true)
		WAVE_TYPES.TUTORIAL_0:
			spawn_target(0, 0)
		WAVE_TYPES.TUTORIAL_1:
			spawn_target(0, 1)
			get_square(0, 0).set_blocked(true)
			get_square(2, 1).set_reflecting(true)
		WAVE_TYPES.TUTORIAL_2:
			spawn_target(3, 0)
			get_square(1, 0).set_blocked(true)
			get_square(3, 1).set_reflecting(true)
		WAVE_TYPES.TUTORIAL_3:
			spawn_target(1, 3)
			get_square(0, 3).set_blocked(true)
			get_square(1, 0).set_reflecting(true)
			get_square(3, 3).set_reflecting(true)
			


func spawn_target(x, y, quick = false, fortified = false):
	targets_alive += 1
	var square = get_square(x, y)
	square.set_quick(quick)
	if fortified:
		square.set_fortified(fortified)
	square.set_targeted(true)
	return square


func spawn_random_target(quick = false, fortified = false):
	while true:
		var rand_x = (randi() % 4)
		var rand_y = (randi() % 4)
		if (rand_x == 0 and rand_y == 0) or (rand_x == 3 and rand_y == 3):
			continue
		return spawn_target(rand_x, rand_y, quick, fortified)

func spawn_centered_target(quick = false, fortified = false):
	while true:
		var rand_x = 1 + (randi() % 2)
		var rand_y = 1 + (randi() % 2)
		var square = get_square(rand_x, rand_y)
		if square.is_tagged():
			continue
		return spawn_target(rand_x, rand_y, quick, fortified)


func spawn_hard_blocker(target : GridNode):
	var choose_x = randi() % 2 == 0
	if target.x == 0:
		choose_x = false
	elif target.y == 0:
		choose_x = true
	while true:
		var rand_x = (randi() % target.x) if choose_x else target.x
		var rand_y = (randi() % target.y) if !choose_x else target.y
		var square = get_square(rand_x, rand_y)
		if square.is_tagged():
			continue
		square.set_blocked(true)
		return square

func spawn_blocker():
	while true:
		var rand_x = (randi() % 4)
		var rand_y = (randi() % 4)
		if rand_x == 3 and rand_y == 3:
			continue
		var square = get_square(rand_x, rand_y)
		if square.is_tagged():
			continue
		square.set_blocked(true)
		return square


func _process(_delta):
	if fortified:
		targets_alive = 2

func on_target_neutralized(node : GridNode):
	targets_alive -= 1
	if !fortified:
		node.set_targeted(false)
	if targets_alive <= 0:
		start_wave()


func on_target_detonated(node : GridNode):
	EnergyManager.take_damage()
	start_wave()


# HELPERS ------------------

func get_square(row, column):
	return get_child(column).get_child(row)
