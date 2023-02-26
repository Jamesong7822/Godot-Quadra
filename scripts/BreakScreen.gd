extends Control

func _ready() -> void:
	# Set the timer
	$BreakTimer.wait_time = Globals.breakTime
	$BreakTimer.start()
	
	
func _process(delta: float) -> void:
	# Update the time left
	$MarginContainer/CenterContainer/VBoxContainer/TimeLeft.text = "%.0f" % $BreakTimer.time_left


func _on_BreakTimer_timeout() -> void:
	# change scene to collab mode
	if get_tree().is_network_server():
		if Globals.currentGameMode == Globals.GAME_MODE.INDIVIDUAL_FIRST:
			Globals.changeGameState(Globals.GAME_TYPE.COLLABORATIVE)
		elif Globals.currentGameMode == Globals.GAME_MODE.COLLABORATIVE_FIRST:
			Globals.changeGameState(Globals.GAME_TYPE.INDIVIDUAL)
		Globals.changeScene(Globals.gameScene)
