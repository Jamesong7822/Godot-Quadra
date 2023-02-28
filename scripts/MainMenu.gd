extends Control

func _ready() -> void:
	# make sure globals restart_game is called
	Globals.restart_game()

func _on_ExitButton_pressed() -> void:
	Network.sendData("STOP_SERVER")
	get_tree().quit()

func _on_StartGameButton_pressed() -> void:
	hide()
	get_tree().change_scene_to(Globals.lobbyPreloadedScene)


func _on_SettingsButton_pressed() -> void:
	hide()
	get_tree().change_scene(Globals.settingsScene)
