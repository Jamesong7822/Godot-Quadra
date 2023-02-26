extends Control

var lobbyScene = preload("res://Lobby.tscn")

func _on_ExitButton_pressed() -> void:
	Network.sendData("STOP_SERVER")
	get_tree().quit()

func _on_StartGameButton_pressed() -> void:
	hide()
	get_tree().change_scene_to(lobbyScene)


func _on_SettingsButton_pressed() -> void:
	hide()
	get_tree().change_scene(Globals.settingsScene)
