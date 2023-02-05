extends Control

func _ready() -> void:
	# Set the timer
	$BreakTimer.wait_time = Globals.BREAK_TIME
	$BreakTimer.start()
	
	
func _process(delta: float) -> void:
	# Update the time left
	$MarginContainer/CenterContainer/VBoxContainer/TimeLeft.text = str($BreakTimer.time_left)


func _on_BreakTimer_timeout() -> void:
	pass # Replace with function body.
	# change scene to collab mode
	Globals.currentGameType = Globals.GAME_TYPE.COLLABORATIVE
	Globals.changeScene(Globals.gameScene)
