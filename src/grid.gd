extends Node2D
class_name GridControl

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
	


func activate(x, y):
	get_square(x, 0).activate_from_up()
	get_square(0, y).activate_from_left()


func start_wave():
	var rand_x = 1 + (randi() % 2)
	var rand_y = 1 + (randi() % 2)
	get_square(rand_x, rand_y).set_targeted(true)


func on_target_neutralized(node : GridNode):
	print_debug("NEUTRALIZED")
	node.set_targeted(false)


# HELPERS ------------------

func get_square(row, column):
	return get_child(column).get_child(row)

