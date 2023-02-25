extends Control

func _ready():
	if get_tree().is_network_server():
		saveUserData(Globals.PLAYER_INFO)


func _on_BackToMenuButton_pressed() -> void:
	Globals.changeScene(Globals.mainMenuScene)
	Network.reset()
