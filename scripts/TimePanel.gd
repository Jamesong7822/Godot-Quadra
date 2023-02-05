extends Control

func _ready() -> void:
	pass
	
func updateTimeRemaining(remainingTime) -> void:
	var minutes = int(remainingTime / 60)
	var seconds = int(remainingTime - minutes*60)
	$HBoxContainer/Label.text = "%d:%02d" %[minutes, seconds]
