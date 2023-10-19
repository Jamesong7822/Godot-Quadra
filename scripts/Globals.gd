extends Node

#const GAME_TIME:float =0.1*60.0 #15.0	# seconds
#const BREAK_TIME:float = 0.1*60.0 # 5.0	# seconds
#const INSTRUCTIONS_TIME:float = 10.0 # seconds

# Game defaults
const DEFAULT_PENALTY_SCORE:int = 100
const DEFAULT_COMBO1:int = 40
const DEFAULT_COMBO2:int = 100
const DEFAULT_COMBO3:int = 300
const DEFAULT_COMBO4:int = 1200
const DEFAULT_GAME_TIME:float = 7 * 60.0 # seconds
#const DEFAULT_BREAK_TIME:float = 2 * 60.0 # seconds
const DEFAULT_INSTRUCTIONS_TIME:float = 10.0 # seconds
const DEFAULT_PRACTICE_TIME:float = 3 * 60.0 # seconds

# debug setings
const DEBUG_PENALTY_SCORE:int = 100
const DEBUG_COMBO1:int = 40
const DEBUG_COMBO2:int = 100
const DEBUG_COMBO3:int = 300
const DEBUG_COMBO4:int = 1200
const DEBUG_GAME_TIME:float = 30.0 # seconds
#const DEBUG_BREAK_TIME:float = 5.0 # seconds
const DEBUG_INSTRUCTIONS_TIME:float = 1.0 # seconds
const DEBUG_PRACTICE_TIME:float = 30.0 # seconds

var penaltyScore = DEFAULT_PENALTY_SCORE
var combo1Score = DEFAULT_COMBO1
var combo2Score = DEFAULT_COMBO2
var combo3Score = DEFAULT_COMBO3
var combo4Score = DEFAULT_COMBO4
var gameTime = DEFAULT_GAME_TIME
#var breakTime = DEFAULT_BREAK_TIME
var instructionsTime = DEFAULT_INSTRUCTIONS_TIME
var practiceTime = DEFAULT_PRACTICE_TIME
var comboScores = {1: combo1Score, 2: combo2Score, 3: combo3Score, 4: combo4Score}

enum GAME_MODE {INDIVIDUAL_FIRST, COLLABORATIVE_FIRST}
enum GAME_TYPE {INDIVIDUAL, BREAK, COLLABORATIVE, END}
enum GAME_CONTROL {NORMAL, MOVE_ONLY, ROTATE_ONLY}

const GAME_LOG_DIR = "DATA"
const GAME_CONFIG_DIR = "CONFIG"

# Special Exit Logging
const EXIT_GAME_LOG_DIR = "EXIT GAME DATA"

var PLAYER_INFO ={}

signal inact_shape
signal update_points
signal gameCtrlUpdate
signal gameModeUpdate

var inactive=[]
var inactive_blocks=[]
var points=0
var speed=1

var numTimesClearBoard = 0
var numRowsCleared = 0
var numCombo1 = 0
var numCombo2 = 0
var numCombo3 = 0
var numCombo4 = 0

var currentGameMode = GAME_MODE.INDIVIDUAL_FIRST
var currentGameType = GAME_TYPE.INDIVIDUAL
var currentGameControl = GAME_CONTROL.NORMAL

## used for combo counting
signal clearRow
signal resetComboCount
var comboCount = 0

# SCENES
var mainMenuScene = "res://MainMenu.tscn"
var breakScreenScene = "res://BreakScreen.tscn"
var gameScene = "res://Main.tscn"
var endGameScene = "res://GameOverScreen.tscn"
var settingsScene = "res://Settings.tscn"
var comboDisplayScene = "res://ComboDisplay.tscn"
var practiceGameScene = "res://PracticeGame.tscn"

var mainMenuPreloadedScene = preload("res://MainMenu.tscn")
var lobbyPreloadedScene = preload("res://Lobby.tscn")

# flag to store if is practice mode
var isPracticeMode = false

func _ready() -> void:
	connect("clearRow", self, "_onClearRow")
	connect("resetComboCount", self, "_onResetComboCount")
	
func _onClearRow() -> void:
	comboCount += 1
	
func _onResetComboCount() -> void:
	# Assign points
	if comboCount != 0:
		add_points(comboCount)
	comboCount = 0

func inactivate_shape():
	emit_signal("inact_shape")

func add_points(rowsCleared:int):
	points+=comboScores[rowsCleared]
	emit_signal("update_points")
	var a = load(comboDisplayScene).instance()
	a.setCombo(rowsCleared)
	get_tree().get_root().get_node("Main/CanvasLayer").add_child(a)
	# update the player game data
	if rowsCleared == 1:
		numCombo1 += 1
	elif rowsCleared == 2:
		numCombo2 += 1
	elif rowsCleared == 3:
		numCombo3 += 1
	elif rowsCleared == 4:
		numCombo4 += 1
	numRowsCleared += rowsCleared
	
remotesync func clearBoard() -> void:
	print("CLEARING BOARD")
	# Subtract penalty from score
	points -= penaltyScore
	for block in get_tree().get_nodes_in_group("BLOCKS"):
		block.queue_free()
	# Clear the inactive blocks
	inactive.clear()
	inactive_blocks.clear()
	# Update counter
	numTimesClearBoard += 1
	emit_signal("update_points")
	
func restart_game():
	# Call this function when going back to main menu
	initializeGameVariables()
	currentGameType = GAME_TYPE.INDIVIDUAL
	currentGameMode = GAME_MODE.INDIVIDUAL_FIRST
	currentGameControl = GAME_CONTROL.NORMAL
	PLAYER_INFO = {}
	# clear practice mode flag
	isPracticeMode = false
	
func initializeGameVariables() -> void:
	speed=1
	points=0
	numTimesClearBoard = 0
	numRowsCleared = 0
	numCombo1 = 0
	numCombo2 = 0
	numCombo3 = 0
	numCombo4 = 0
	inactive.clear()
	inactive_blocks.clear()
	emit_signal("update_points")
	
func changeScene(scene):
	if get_tree().is_network_server():
		rpc("syncScene", scene)
	
remotesync func syncScene(scene):
	get_tree().change_scene(scene)
	
func changeGameState(newGameState):
	if get_tree().is_network_server():
		rpc("updateGameState", newGameState)

remotesync func updateGameState(newGameState):
	currentGameType = newGameState
	
func assignGameControl(gameControl):
	rpc("updateGameControl", gameControl)

remotesync func updateGameControl(gameControl):
	print("Game Control: %s" % gameControl)
	var ctrl = gameControl[get_tree().get_network_unique_id()]
	currentGameControl = ctrl
	emit_signal("gameCtrlUpdate")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Network.sendData("STOP_SERVER")
		# SAVE DATA HERE
		createDirIfRequired(EXIT_GAME_LOG_DIR)
		saveUserData(EXIT_GAME_LOG_DIR, PLAYER_INFO)
		get_tree().quit() # default behavior
		
remotesync func syncGameMode(gameMode:bool) -> void:
	if gameMode:
		currentGameMode = GAME_MODE.COLLABORATIVE_FIRST
		print("Setting Game Mode To Collaborative First!")
	else:
		currentGameMode = GAME_MODE.INDIVIDUAL_FIRST
		print("Setting Game Mode To Individual First!")
		
	if currentGameMode == GAME_MODE.COLLABORATIVE_FIRST:
		currentGameType = GAME_TYPE.COLLABORATIVE
	else:
		currentGameType = GAME_TYPE.INDIVIDUAL
	emit_signal("gameModeUpdate")
		
remote func syncGameSettings(settings) -> void:
	penaltyScore = settings["PenaltyScore"]
	combo1Score = settings["Combo1"]
	combo2Score = settings["Combo2"]
	combo3Score = settings["Combo3"]
	combo4Score = settings["Combo4"]
	gameTime = settings["GameTime"]
	#breakTime = settings["BreakTime"]
	instructionsTime = settings["InstructionsTime"]
	practiceTime = settings["PracticeTime"]
	
func getGameSettings() -> Dictionary:
	var settings = {}
	settings["PenaltyScore"] = penaltyScore
	settings["Combo1"] = combo1Score
	settings["Combo2"] = combo2Score
	settings["Combo3"] = combo3Score
	settings["Combo4"] = combo4Score
	settings["GameTime"] = gameTime
	#settings["BreakTime"] = breakTime
	settings["InstructionsTime"] = instructionsTime
	settings["PracticeTime"] = practiceTime
	return settings
	
remotesync func updateCollabScores() -> void:
	PLAYER_INFO[get_tree().get_network_unique_id()]["CScore"] = str(points)
	PLAYER_INFO[get_tree().get_network_unique_id()]["CNumRowsCleared"] = str(numRowsCleared)
	PLAYER_INFO[get_tree().get_network_unique_id()]["CNumCombo1"] = str(numCombo1)
	PLAYER_INFO[get_tree().get_network_unique_id()]["CNumCombo2"] = str(numCombo2)
	PLAYER_INFO[get_tree().get_network_unique_id()]["CNumCombo3"] = str(numCombo3)
	PLAYER_INFO[get_tree().get_network_unique_id()]["CNumCombo4"] = str(numCombo4)
	PLAYER_INFO[get_tree().get_network_unique_id()]["CNumTimesDied"] = str(numTimesClearBoard)
	PLAYER_INFO[get_tree().get_network_unique_id()]["CGameControl"] = str(GAME_CONTROL.keys()[currentGameControl])
	
remotesync func updateIndivScores() -> void:
	PLAYER_INFO[get_tree().get_network_unique_id()]["IScore"] = str(points)
	PLAYER_INFO[get_tree().get_network_unique_id()]["INumRowsCleared"] = str(numRowsCleared)
	PLAYER_INFO[get_tree().get_network_unique_id()]["INumCombo1"] = str(numCombo1)
	PLAYER_INFO[get_tree().get_network_unique_id()]["INumCombo2"] = str(numCombo2)
	PLAYER_INFO[get_tree().get_network_unique_id()]["INumCombo3"] = str(numCombo3)
	PLAYER_INFO[get_tree().get_network_unique_id()]["INumCombo4"] = str(numCombo4)
	PLAYER_INFO[get_tree().get_network_unique_id()]["INumTimesDied"] = str(numTimesClearBoard)
	
remote func informServerMyScores(gameInfo:Dictionary) -> void:
	print("Client Send Over Score: %s" % gameInfo)
	var clientId = get_tree().get_rpc_sender_id()
	PLAYER_INFO[clientId] = gameInfo[clientId]
	get_tree().get_root().get_node("GameOverScreen").emit_signal("clientSentOverScores")
	
remote func askClientForScores() -> void:
	if get_tree().get_rpc_sender_id() != 1:
		return
	print("Receive Server's Asking For Client's Score")
	rpc("informServerMyScores", Globals.PLAYER_INFO)

func createDirIfRequired(directory:String) -> void:
	# Special function to create a directory if it does not exist
	var dir = Directory.new()
	if not dir.dir_exists(directory):
		print("%s does not exist. Creating!" % directory)
		dir.open(".")
		var err = dir.make_dir(directory)
		if err != OK:
			print("Error Creating %s with error code: %s" % [directory, err])

func saveUserData(directory:String, data:Dictionary):
	var date = Time.get_date_string_from_system()
	var time = OS.get_time()
	var filename = "%s/%s %s_%s_%s.txt" % [directory, date, str(time.hour), str(time.minute), str(time.second)]
	var saveHandle = File.new()
	var err = saveHandle.open(filename, File.WRITE)
	if err != OK:
		print("Error Saving User Data! %s" % err)
	else:
		var csv = []
		var playerList = data.keys()
		if len(playerList) < 1:
			# No player info
			pass
		else:
			var headers = data[1].keys()
			saveHandle.store_csv_line(headers)
			for player in playerList:
				var playerData = []
				for key in headers:
					playerData.append(data[player][key])
				saveHandle.store_csv_line(playerData)
			saveHandle.close()
			print("Saved User Data In: %s" % filename)
