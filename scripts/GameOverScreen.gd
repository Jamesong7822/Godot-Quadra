extends Control

func _ready():
	if get_tree().is_network_server():
		saveUserData(Globals.PLAYER_INFO)

func saveUserData(dict):
	var date = Time.get_date_string_from_system()
	var time = OS.get_time()
	var filename = "%s - %s:%s:%s.txt" % [date, str(time.hour), str(time.minute), str(time.second)]
	var saveHandle = File.new()
	saveHandle.open(filename, File.WRITE)
	var csv = []
	var playerList = dict.keys()
	var headers = dict[1].keys()
	saveHandle.store_csv_line(headers)
	for player in playerList:
		var playerData = []
		for key in headers:
			playerData.append(dict[player][key])
		saveHandle.store_csv_line(playerData)
	saveHandle.close()

func _on_BackToMenuButton_pressed() -> void:
	Globals.changeScene(Globals.mainMenuScene)
	Network.reset()
