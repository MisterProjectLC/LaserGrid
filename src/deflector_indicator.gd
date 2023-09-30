extends ResourceIndicator


# Called when the node enters the scene tree for the first time.
func _ready():
	EnergyManager.reflectors_updated.connect(update_resource)
