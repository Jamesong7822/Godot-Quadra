extends Node2D

onready var shape1=preload("res://Shape1.tscn")
onready var shape2=preload("res://Shape2.tscn")
onready var shape3=preload("res://Shape3.tscn")
onready var shape4=preload("res://Shape4.tscn")
onready var shape5=preload("res://Shape5.tscn")
onready var shape6=preload("res://Shape6.tscn")
onready var shape7=preload("res://Shape7.tscn")
var shapes=[]
var sh
var active_block=false
var rnd=RandomNumberGenerator.new()
var num:int=-1
var next_num:int=0
var counter:int=0

func _ready():
	#Display instructions for fixed time
	yield(get_tree().create_timer(5.0), "timeout")
	#$Timer.wait_time=Globals.INSTRUCTION_TIME
	$CanvasLayer/InstructionScreen.hide()
	# Call restart game
	Globals.initializeGameVariables()
	shapes=[shape1,shape2,shape3,shape4,shape5,shape6,shape7]
	rnd.randomize()
	if get_tree().is_network_server():
		var randomSeed = rnd.randi()
		rpc("syncRandomSeed", randomSeed)

	# Connect Signals
	Globals.connect("gameCtrlUpdate", self, "onGameCtrlUpdate")
	
	yield(get_tree().create_timer(0.5), "timeout")
	$Timer.wait_time=Globals.speed
	
	# Assign game control if required
	assignGameControl()

	if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
		$Timer.start()
	elif Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE:
		if get_tree().is_network_server():
			$Timer.start()
	# Start game timer
	$GameTimer.wait_time = Globals.GAME_TIME
	$GameTimer.start()
	
func onGameCtrlUpdate() -> void:
	print("Game Ctrl Update!")
	# Update the game type & control
	$CanvasLayer/HUD/HBoxContainer/GameInfoContainer/GameTypeLabel.text = str(Globals.GAME_TYPE.keys()[Globals.currentGameType])
	$CanvasLayer/HUD/HBoxContainer/GameInfoContainer/GameControlLabel.text = str(Globals.GAME_CONTROL.keys()[Globals.currentGameControl])
	
remotesync func syncRandomSeed(seedVal):
	print("Received Random Seed: %d" %seedVal)
	rnd.seed = seedVal

func _process(delta: float) -> void:
	# Update the game time label
	$CanvasLayer/HUD/HBoxContainer/VBoxContainer/TimePanel.updateTimeRemaining($GameTimer.time_left)

func assignGameControl() -> void:
	if not get_tree().is_network_server():
		return
	if Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE:
		var ctrl = rnd.randi()%2
		var ctrlDict
		if ctrl == 0:
			# server is movement type control, client is rotate type control
			ctrlDict = {1:Globals.GAME_CONTROL.MOVE_ONLY}
			if len(Network.clients):
				ctrlDict[Network.clients[0]] = Globals.GAME_CONTROL.ROTATE_ONLY
		else:
			# server is rotate type control, client is movement type control
			ctrlDict = {1:Globals.GAME_CONTROL.ROTATE_ONLY}
			if len(Network.clients):
				ctrlDict[Network.clients[0]] = Globals.GAME_CONTROL.MOVE_ONLY
		Globals.assignGameControl(ctrlDict)

func _on_Timer_timeout():
	if not active_block:
		num=rnd.randi()%7 if num==-1 else next_num
		next_num=rnd.randi()%7
		if Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE and get_tree().is_network_server():
			rpc("spawnBlock", num, next_num, counter)
		elif Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			spawnBlock(num, next_num, counter)
		
	else:
		if Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE and get_tree().is_network_server():
			rpc("move_down")
		elif Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			move_down()
		
remotesync func spawnBlock(num, next_num, counter) -> void:
	if Globals.currentGameType != Globals.GAME_TYPE.INDIVIDUAL and Globals.currentGameType != Globals.GAME_TYPE.COLLABORATIVE:
		return
	$CanvasLayer/HUD/HBoxContainer/NextShapePanel/VBoxContainer/Control/Sprite.frame=next_num
	sh=shapes[num].instance()
	sh.name = "Shape%s" %str(counter)
	$ShapesArea.add_child(sh)
	sh.position=Vector2(320,80)
	active_block=true
	$Timer.start()
	counter += 1

remotesync func move_left():
	if not active_block:
		return
	sh.move_left()

remotesync func move_right():
	if not active_block:
		return
	sh.move_right()

remotesync func move_down():
	if not active_block:
		return
	sh.move_down()
	
remotesync func userInputMoveDown():
	if not active_block:
		return
	sh.move_down()
		
remotesync func rotate_shape():
	if not active_block:
		return
	sh.rotate_it()

func _input(event):
	if not sh:
		return
	if Input.is_action_just_pressed("ui_right"):
		if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			move_right()
		else:
			if Globals.currentGameControl == Globals.GAME_CONTROL.MOVE_ONLY or Globals.currentGameControl == Globals.GAME_CONTROL.NORMAL:
				rpc("move_right")
	if Input.is_action_just_pressed("ui_left"):
		if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			move_left()
		else:
			if Globals.currentGameControl == Globals.GAME_CONTROL.MOVE_ONLY or Globals.currentGameControl == Globals.GAME_CONTROL.NORMAL:
				rpc("move_left")
	if Input.is_action_just_pressed("ui_down"):
		if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			userInputMoveDown()
		else:
			if Globals.currentGameControl == Globals.GAME_CONTROL.MOVE_ONLY or Globals.currentGameControl == Globals.GAME_CONTROL.NORMAL:
				rpc("userInputMoveDown")
	if Input.is_action_just_pressed("ui_up"):
		if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			rotate_shape()
		else:
			if Globals.currentGameControl == Globals.GAME_CONTROL.ROTATE_ONLY or Globals.currentGameControl == Globals.GAME_CONTROL.NORMAL:
				rpc("rotate_shape")

func _on_GameTimer_timeout() -> void:
#	if not get_tree().is_network_server():
#		return
	if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
		# Go To Break
		Globals.changeGameState(Globals.GAME_TYPE.BREAK)
		# change scene
		Globals.changeScene(Globals.breakScreenScene)
	elif Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE:
		# Go To End Game Scene
		Globals.changeGameState(Globals.GAME_TYPE.END)
		# change scene
		Globals.changeScene((Globals.endGameScene))
