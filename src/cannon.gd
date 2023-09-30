extends Node2D


func _ready():
	$Sprite2D.modulate = Palletes.CANNON_COLOR


func activate():
	$Laser.activate()
