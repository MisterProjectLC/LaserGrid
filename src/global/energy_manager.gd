extends Node

signal died()
signal health_updated(health)
signal reflectors_updated(reflectors)

@export var MAX_HEALTH = 3
@onready var health = MAX_HEALTH

@export var MAX_REFLECTORS = 4
@onready var reflectors = MAX_REFLECTORS


func reset():
	health = MAX_HEALTH
	reflectors = MAX_REFLECTORS

func get_health():
	return health


func take_damage():
	health -= 1
	health_updated.emit(health)
	if health <= 0:
		died.emit()


func heal():
	health = min(health+1, MAX_HEALTH)
	health_updated.emit(health)


func spend_reflector():
	if reflectors <= 0:
		return false
	
	reflectors -= 1
	reflectors_updated.emit(reflectors)
	return true


func return_reflector():
	reflectors = min(reflectors+1, MAX_REFLECTORS)
	reflectors_updated.emit(reflectors)
