extends Control

func _ready():
	if get_tree().is_network_server():
		saveUserData(Globals.PLAYER_INFO)

func saveUserData(dict):
	var datetime_string = Time.get_datetime_string_from_system()
	var filename = "%s.txt" % datetime_string
	var saveHandle = File.new()
	saveHandle.open(filename, File.WRITE)
	saveHandle.store_line(to_json(dict))
	saveHandle.close()

func _on_BackToMenuButton_pressed() -> void:
	Globals.changeScene(Globals.mainMenuScene)
	Network.reset()
