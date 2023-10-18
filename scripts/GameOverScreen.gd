extends Control

signal clientSentOverScores

func _ready():
	# If is practice mode we hide the watch instructions
	if Globals.isPracticeMode:
		$MarginContainer/VBoxContainer/WatchInstructions.hide()
	connect("clientSentOverScores", self, "onClientSentOverScores")
	if get_tree().is_network_server():
		print("Server Asking Client For Score")
		Globals.rpc("askClientForScores")
	# Fill up the debug info
	$MarginContainer/VBoxContainer/DebugInfo.text = str(Globals.PLAYER_INFO)

func _on_BackToMenuButton_pressed() -> void:
	get_tree().change_scene_to(Globals.mainMenuPreloadedScene)
	Network.reset()
	
func onClientSentOverScores() -> void:
	Globals.createDirIfRequired(Globals.GAME_LOG_DIR)
	if get_tree().is_network_server():
		Globals.saveUserData(Globals.GAME_LOG_DIR, Globals.PLAYER_INFO)
