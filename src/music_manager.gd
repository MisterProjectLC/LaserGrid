extends Node

var current_song = 0
var waiting_song = 0

func switch_song(new_song):
	waiting_song = new_song


func play_outro():
	$Outro.play()


func _on_finished():
	get_child(waiting_song).play()
	
	if current_song != waiting_song:
		get_child(current_song).finished.disconnect(_on_finished)
		get_child(waiting_song).finished.connect(_on_finished)
		current_song = waiting_song
