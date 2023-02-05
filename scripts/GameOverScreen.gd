extends Control



func _on_BackToMenuButton_pressed() -> void:
	Globals.changeScene(Globals.mainMenuScene)
	Network.reset()
