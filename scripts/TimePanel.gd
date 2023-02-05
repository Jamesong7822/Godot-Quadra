extends Control

func _ready() -> void:
	pass
	
func updateTimeRemaining(remainingTime) -> void:
	$HBoxContainer/Label.text = str(remainingTime)
