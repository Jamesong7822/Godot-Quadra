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

# debug setings
const DEBUG_PENALTY_SCORE:int = 100
const DEBUG_COMBO1:int = 40
const DEBUG_COMBO2:int = 100
const DEBUG_COMBO3:int = 300
const DEBUG_COMBO4:int = 1200
const DEBUG_GAME_TIME:float = 30.0 # seconds
#const DEBUG_BREAK_TIME:float = 5.0 # seconds
const DEBUG_INSTRUCTIONS_TIME:float = 1.0 # seconds

var penaltyScore = DEFAULT_PENALTY_SCORE
var combo1Score = DEFAULT_COMBO1
var combo2Score = DEFAULT_COMBO2
var combo3Score = DEFAULT_COMBO3
var combo4Score = DEFAULT_COMBO4
var gameTime = DEFAULT_GAME_TIME
#var breakTime = DEFAULT_BREAK_TIME
var instructionsTime = DEFAULT_INSTRUCTIONS_TIME

enum GAME_MODE {INDIVIDUAL_FIRST, COLLABORATIVE_FIRST}
enum GAME_TYPE {INDIVIDUAL, BREAK, COLLABORATIVE, END}
enum GAME_CONTROL {NORMAL, MOVE_ONLY, ROTATE_ONLY}

const GAME_LOG_DIR = "DATA"
const GAME_CONFIG_DIR = "CONFIG"

var PLAYER_INFO ={}

signal inact_shape
signal update_points
signal gameCtrlUpdate

var inactive=[]
var inactive_blocks=[]
var points=0
var speed=1

var numTimesClearBoard = 0

var currentGameMode = GAME_MODE.INDIVIDUAL_FIRST
var currentGameType = GAME_TYPE.INDIVIDUAL
var currentGameControl = GAME_CONTROL.NORMAL

# SCENES
var mainMenuScene = "res://MainMenu.tscn"
var breakScreenScene = "res://BreakScreen.tscn"
var gameScene = "res://Main.tscn"
var endGameScene = "res://GameOverScreen.tscn"
var settingsScene = "res://Settings.tscn"

func inactivate_shape():
	emit_signal("inact_shape")

func add_points():
	points+=100
	if points%100==0 and speed>.3:
		speed-=.1
	emit_signal("update_points")
	
remotesync func clearBoard() -> void:
	print("CLEARING BOARD")
	# Subtract penalty from score
	points -= penaltyScore
	for block in inactive_blocks:
		block.queue_free()
	# Clear the inactive blocks
	inactive.clear()
	inactive_blocks.clear()
	# Update counter
	numTimesClearBoard += 1
	emit_signal("update_points")
	
func restart_game():
	initializeGameVariables()
	get_tree().reload_current_scene()
	
func initializeGameVariables() -> void:
	speed=1
	points=0
	numTimesClearBoard = 0
	inactive.clear()
	inactive_blocks.clear()
	emit_signal("update_points")
	
func changeScene(scene):
	rpc("syncScene", scene)
	
remotesync func syncScene(scene):
	get_tree().change_scene(scene)
	
func changeGameState(newGameState):
	rpc("updateGameState", newGameState)

remotesync func updateGameState(newGameState):
	currentGameType = newGameState
	
func assignGameControl(gameControl):
	rpc("updateGameControl", gameControl)

remotesync func updateGameControl(gameControl):
	print(gameControl)
	var ctrl = gameControl[get_tree().get_network_unique_id()]
	currentGameControl = ctrl
	emit_signal("gameCtrlUpdate")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Network.sendData("STOP_SERVER")
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
		
remote func syncGameSettings(settings) -> void:
	penaltyScore = settings["PenaltyScore"]
	combo1Score = settings["Combo1"]
	combo2Score = settings["Combo2"]
	combo3Score = settings["Combo3"]
	combo4Score = settings["Combo4"]
	gameTime = settings["GameTime"]
	#breakTime = settings["BreakTime"]
	instructionsTime = settings["InstructionsTime"]
	
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
	return settings
