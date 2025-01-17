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
	# give enuff time for the rpc for send sever game score
	# to work which is called by client
	yield(get_tree().create_timer(1), "timeout")

func createDirIfRequired() -> void:
	var dir = Directory.new()
	if not dir.dir_exists(Globals.GAME_LOG_DIR):
		print("%s does not exist. Creating!" % Globals.GAME_LOG_DIR)
		dir.open(".")
		var err = dir.make_dir(Globals.GAME_LOG_DIR)
		if err != OK:
			print("Error Creating %s with error code: %s" % [Globals.GAME_LOG_DIR, err])

func saveUserData(dict):
	var date = Time.get_date_string_from_system()
	var time = OS.get_time()
	var filename = "%s/%s %s_%s_%s.txt" % [Globals.GAME_LOG_DIR, date, str(time.hour), str(time.minute), str(time.second)]
	var saveHandle = File.new()
	var err = saveHandle.open(filename, File.WRITE)
	if err != OK:
		print("Error Saving User Data! %s" % err)
	else:
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
		print("Saved User Data In: %s" % filename)

func _on_BackToMenuButton_pressed() -> void:
	get_tree().change_scene_to(Globals.mainMenuPreloadedScene)
	Network.reset()
	
func onClientSentOverScores() -> void:
	createDirIfRequired()
	if get_tree().is_network_server():
		saveUserData(Globals.PLAYER_INFO)
