extends Node

const GAME_TIME:float =7*60.0 #15.0	# seconds
const BREAK_TIME:float = 2*60.0 # 5.0	# seconds

enum GAME_TYPE {INDIVIDUAL, BREAK, COLLABORATIVE, END}
enum GAME_CONTROL {NORMAL, MOVE_ONLY, ROTATE_ONLY}

signal inact_shape
signal add_points
signal gameCtrlUpdate

var inactive=[]
var inactive_blocks=[]
var points=0
var speed=1

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
	emit_signal("add_points")
	
func restart_game():
	speed=1
	points=0
	inactive.clear()
	inactive_blocks.clear()
	get_tree().reload_current_scene()
	
func initializeGameVariables() -> void:
	speed=1
	points=0
	inactive.clear()
	inactive_blocks.clear()
	
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
