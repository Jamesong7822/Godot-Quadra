extends Control

onready var penaltyScore = $MarginContainer/MarginContainer/VBoxContainer/GridContainer/PenaltyScore
onready var combo1Score = $"MarginContainer/MarginContainer/VBoxContainer/GridContainer/ComboScore-Row1"
onready var combo2Score = $"MarginContainer/MarginContainer/VBoxContainer/GridContainer/ComboScore-Row2"
onready var combo3Score = $"MarginContainer/MarginContainer/VBoxContainer/GridContainer/ComboScore-Row3"
onready var combo4Score = $"MarginContainer/MarginContainer/VBoxContainer/GridContainer/ComboScore-Row4"
onready var gameTime = $MarginContainer/MarginContainer/VBoxContainer/GridContainer/GameTime
onready var breakTime = $MarginContainer/MarginContainer/VBoxContainer/GridContainer/BreakTime
onready var instructionsTime = $MarginContainer/MarginContainer/VBoxContainer/GridContainer/InstructionsTime

func _ready() -> void:
	createDirIfRequired()
	# Load In Configuration From File
	loadSettings()
	
func createDirIfRequired() -> void:
	var dir = Directory.new()
	if not dir.dir_exists(Globals.GAME_CONFIG_DIR):
		dir.make_dir(Globals.GAME_CONFIG_DIR)
		
func checkIfConfigFileExists() -> bool:
	var dir = Directory.new()
	if dir.file_exists("%s/config.json" % Globals.GAME_CONFIG_DIR):
		return true
	return false
	
func loadSettings() -> void:
	if checkIfConfigFileExists():
		var filepath = "%s/config.json" % Globals.GAME_CONFIG_DIR
		var file = File.new()
		file.open(filepath, File.READ)
		var settingsTxt = file.get_as_text()
		var settings = parse_json(settingsTxt)
		penaltyScore.value = settings["PenaltyScore"]
		combo1Score.value = settings["Combo1"]
		combo2Score.value = settings["Combo2"]
		combo3Score.value = settings["Combo3"]
		combo4Score.value = settings["Combo4"]
		gameTime.value = settings["GameTime"]
		breakTime.value = settings["BreakTime"]
		instructionsTime.value = settings["InstructionsTime"]
	else:
		setToDefaultSettings()
		# save the settings
		saveSettings()
		
func updateSettings(value_:float) -> void:
	Globals.penaltyScore = penaltyScore.value
	Globals.combo1Score = combo1Score.value
	Globals.combo2Score = combo2Score.value
	Globals.combo3Score = combo3Score.value
	Globals.combo4Score = combo4Score.value
	Globals.gameTime = gameTime.value
	Globals.breakTime = breakTime.value
	Globals.instructionsTime = instructionsTime.value
		
func setToDefaultSettings() -> void:
	# use the default values in Globals
	penaltyScore.value = Globals.DEFAULT_PENALTY_SCORE
	combo1Score.value = Globals.DEFAULT_COMBO1
	combo2Score.value = Globals.DEFAULT_COMBO2
	combo3Score.value = Globals.DEFAULT_COMBO3
	combo4Score.value = Globals.DEFAULT_COMBO4
	gameTime.value = Globals.DEFAULT_GAME_TIME
	breakTime.value = Globals.DEFAULT_BREAK_TIME
	instructionsTime.value = Globals.DEFAULT_INSTRUCTIONS_TIME
	
func setToDebugSettings() -> void:
	# use the default values in Globals
	penaltyScore.value = Globals.DEBUG_PENALTY_SCORE
	combo1Score.value = Globals.DEBUG_COMBO1
	combo2Score.value = Globals.DEBUG_COMBO2
	combo3Score.value = Globals.DEBUG_COMBO3
	combo4Score.value = Globals.DEBUG_COMBO4
	gameTime.value = Globals.DEBUG_GAME_TIME
	breakTime.value = Globals.DEBUG_BREAK_TIME
	instructionsTime.value = Globals.DEBUG_INSTRUCTIONS_TIME

func saveSettings() -> void:
	var settings = {}
	settings["PenaltyScore"] = penaltyScore.value
	settings["Combo1"] = combo1Score.value
	settings["Combo2"] = combo2Score.value
	settings["Combo3"] = combo3Score.value
	settings["Combo4"] = combo4Score.value
	settings["GameTime"] = gameTime.value
	settings["BreakTime"] = breakTime.value
	settings["InstructionsTime"] = instructionsTime.value
	var filepath = "%s/config.json" % Globals.GAME_CONFIG_DIR
	var file = File.new()
	file.open(filepath, File.WRITE)
	var jsonStr = JSON.print(settings)
	file.store_string(jsonStr)
	file.close()
	print("Save Settings To %s"%filepath)

func _on_BackToMenu_pressed() -> void:
	hide()
	get_tree().change_scene(Globals.mainMenuScene)
