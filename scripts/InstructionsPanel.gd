extends TextureRect

signal finished

func _ready() -> void:
	show()
	$Timer.wait_time = Globals.instructionsTime
	$Timer.start()
	
func _process(delta: float) -> void:
	# update the time label with how much time left
	$CenterContainer/TimeLabel.text = "%.0f" % $Timer.time_left

func _on_Timer_timeout() -> void:
	emit_signal("finished")
	queue_free()
