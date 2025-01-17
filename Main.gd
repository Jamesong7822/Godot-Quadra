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
var colours = [Color.gold, Color.royalblue, Color.indianred, Color.yellowgreen, Color.darkorange, Color.darkturquoise, Color.orchid]
var active_block=false
var rnd=RandomNumberGenerator.new()
var num:int=-1
var next_num:int=0
var colorNum:int=-1
var nextColorNum:int=0
var counter:int=0

var lastUserInputMoveDownTime:int=0
export(int, 1, 1000) var dropDelay:int

func _ready():
	# Connect Signals
	Globals.connect("gameCtrlUpdate", self, "onGameCtrlUpdate")
	$CanvasLayer/InstructionsPanel.connect("finished", self, "on_instructions_panel_finished")
	
func onGameCtrlUpdate() -> void:
	print("Game Ctrl Update!")
	# Update the game type & control
	$CanvasLayer/HUD/HBoxContainer/GameInfoContainer/GameTypeLabel.text = str(Globals.GAME_TYPE.keys()[Globals.currentGameType])
	$CanvasLayer/HUD/HBoxContainer/GameInfoContainer/GameControlLabel.text = str(Globals.GAME_CONTROL.keys()[Globals.currentGameControl])
	
func on_instructions_panel_finished() -> void:
	# start the game
	if get_tree().is_network_server():
		rpc("startGame")

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
		var ctrlDict
		# server is rotate type control, client is movement type control
		ctrlDict = {1:Globals.GAME_CONTROL.ROTATE_ONLY}
		if len(Network.clients):
			ctrlDict[Network.clients[0]] = Globals.GAME_CONTROL.MOVE_ONLY
		Globals.assignGameControl(ctrlDict)

func _on_Timer_timeout():
	if not active_block:
		num=rnd.randi()%7 if num==-1 else next_num
		next_num=rnd.randi()%7
		colorNum = rnd.randi()%7 if num ==-1 else nextColorNum
		nextColorNum = rnd.randi()%7
		if Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE and get_tree().is_network_server():
			rpc("spawnBlock", num, next_num, colorNum, nextColorNum, counter)
		elif Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			spawnBlock(num, next_num, colorNum,nextColorNum, counter)
		counter += 1
		$CanvasLayer/HUD/HBoxContainer/NextShapePanel/VBoxContainer/Control/Sprite.visible = true
	else:
		if Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE and get_tree().is_network_server():
			rpc("move_down")
		elif Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			move_down()

remotesync func startGame() -> void:
	# Call the function via RPC to sync the start of the game
	Globals.initializeGameVariables()
	$Timer.wait_time=Globals.speed
	shapes=[shape1,shape2,shape3,shape4,shape5,shape6,shape7]
	rnd.randomize()
	if get_tree().is_network_server():
		var randomSeed = rnd.randi()
		rpc("syncRandomSeed", randomSeed)
	
	# Assign game control if required
	assignGameControl()

	if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
		$Timer.start()
	elif Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE:
		if get_tree().is_network_server():
			$Timer.start()
	# Sync the game timer to server
	# Start game timer
	if get_tree().is_network_server():
		$GameTimer.wait_time = Globals.gameTime
		$GameTimer.start()
	
	# Send Event Signal
	if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
		Network.sendData("START_I")
	elif Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE:
		Network.sendData("START_C")
		
	$SyncTimer.start()
		
remote func syncGameTimer(gameTime) -> void:
	if get_tree().get_rpc_sender_id() == 1:
		$GameTimer.wait_time = gameTime
		$GameTimer.start()
		
remotesync func spawnBlock(num, next_num, colorNum, nextColorNum, counter) -> void:
	if Globals.currentGameType != Globals.GAME_TYPE.INDIVIDUAL and Globals.currentGameType != Globals.GAME_TYPE.COLLABORATIVE:
		return
	$CanvasLayer/HUD/HBoxContainer/NextShapePanel/VBoxContainer/Control/Sprite.visible = true
	$CanvasLayer/HUD/HBoxContainer/NextShapePanel/VBoxContainer/Control/Sprite.frame=next_num
	$CanvasLayer/HUD/HBoxContainer/NextShapePanel/VBoxContainer/Control/Sprite.modulate = colours[nextColorNum]
	sh=shapes[num].instance()
	sh.name = "Shape%s" %str(counter)
	$ShapesArea.add_child(sh)
	sh.position=Vector2(320,80)
	sh.modulate = colours[colorNum]
	active_block=true
	$Timer.start()

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
	if not sh or not active_block:
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
	if Input.is_action_pressed("ui_down"):
		if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			var currentTime = OS.get_ticks_msec()
			if currentTime - lastUserInputMoveDownTime > dropDelay:
				# every 100ms can send a userinput move down command
				if active_block:
					userInputMoveDown()
				lastUserInputMoveDownTime = currentTime
		else:
			if Globals.currentGameControl == Globals.GAME_CONTROL.ROTATE_ONLY or Globals.currentGameControl == Globals.GAME_CONTROL.NORMAL:
				var currentTime = OS.get_ticks_msec()
				if currentTime - lastUserInputMoveDownTime > dropDelay:
					if active_block:
						rpc("userInputMoveDown")
						lastUserInputMoveDownTime = currentTime
	if Input.is_action_just_pressed("ui_up"):
		if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			rotate_shape()
		else:
			if Globals.currentGameControl == Globals.GAME_CONTROL.ROTATE_ONLY or Globals.currentGameControl == Globals.GAME_CONTROL.NORMAL:
				rpc("rotate_shape")

func _on_GameTimer_timeout() -> void:
#	if not get_tree().is_network_server():
#		return
	print("GAME TIMER TIMEOUT")
	if Globals.currentGameMode == Globals.GAME_MODE.INDIVIDUAL_FIRST:
		if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			# Save to player dict
			Globals.rpc("updateIndivScores")
			
			print(Globals.PLAYER_INFO)
			# Send event
			Network.sendData("END_I")
			# Go To Break
			Globals.changeGameState(Globals.GAME_TYPE.BREAK)
			# change scene
			Globals.changeScene(Globals.breakScreenScene)
			
		elif Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE:
			# Save to player dict first
			Globals.rpc("updateCollabScores")
			
			print(Globals.PLAYER_INFO)
			
			# Send End Event
			Network.sendData("END_C")
			# Go To End Game Scene
			Globals.changeGameState(Globals.GAME_TYPE.END)
			# change scene
			Globals.changeScene((Globals.endGameScene))
			
	else:
		# COLLAB FIRST
		if Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE:
			# Save to player dict first
			Globals.rpc("updateCollabScores")
			
			print(Globals.PLAYER_INFO)
			# Send event
			Network.sendData("END_C")
			# Go To Break
			Globals.changeGameState(Globals.GAME_TYPE.BREAK)
			# change scene
			Globals.changeScene(Globals.breakScreenScene)
			
		elif Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			# Save to player dict
			Globals.rpc("updateIndivScores")
			
			print(Globals.PLAYER_INFO)
			
			# Send End Event
			Network.sendData("END_I")
			# Go To End Game Scene
			Globals.changeGameState(Globals.GAME_TYPE.END)
			# change scene
			Globals.changeScene((Globals.endGameScene))

func _on_SyncTimer_timeout() -> void:
	# Sync game time
	if get_tree().is_network_server():
		rpc("syncGameTimer", $GameTimer.time_left)
