extends Node

const GAME_TIME:float =1*60.0 #15.0	# seconds
const BREAK_TIME:float = 0.1*60.0 # 5.0	# seconds
const INSTRUCTIONS_TIME:float = 10.0 # seconds

const CLEAR_BOARD_PENALTY:int = 100

enum GAME_MODE {INDIVIDUAL_FIRST, COLLABORATIVE_FIRST}
enum GAME_TYPE {INDIVIDUAL, BREAK, COLLABORATIVE, END}
enum GAME_CONTROL {NORMAL, MOVE_ONLY, ROTATE_ONLY}

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
	points -= CLEAR_BOARD_PENALTY
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
