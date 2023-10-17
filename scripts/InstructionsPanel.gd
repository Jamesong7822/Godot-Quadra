extends TextureRect
export (Array, Texture) var InstructionImages

signal finished

func _ready() -> void:
	if Globals.isPracticeMode:
		texture = InstructionImages[3]
	elif Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
		texture = InstructionImages[0]
	elif Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE:
		if get_tree().is_network_server():
			texture = InstructionImages[1]
		else:
			texture = InstructionImages[2]
	show()
	$Timer.wait_time = Globals.instructionsTime
	$Timer.start()
	
func _process(delta: float) -> void:
	# update the time label with how much time left
	$CenterContainer/TimeLabel.text = "%.0f" % $Timer.time_left

func _on_Timer_timeout() -> void:
	emit_signal("finished")
	queue_free()
