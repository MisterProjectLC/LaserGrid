extends Node2D
class_name ResourceIndicator


func update_resource(value):
	for i in range(value):
		get_child(i).visible = true
	for i in range(value, get_child_count()):
		get_child(i).visible = false


