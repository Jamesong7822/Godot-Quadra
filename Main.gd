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

func _ready():
	shapes=[shape1,shape2,shape3,shape4,shape5,shape6,shape7]
	rnd.randomize()
	$Timer.wait_time=Globals.speed
	if get_tree().is_network_server():
		$Timer.start()
	# Start game timer
	$GameTimer.wait_time = Globals.GAME_TIME
	$GameTimer.start()
	# Update the game type
	$CanvasLayer/HUD/HBoxContainer/GameTypeLabel.text = str(Globals.GAME_TYPE.keys()[Globals.currentGameType])

func _on_Timer_timeout():
	if not active_block:
		num=rnd.randi()%7 if num==-1 else next_num
		next_num=rnd.randi()%7
		if get_tree().is_network_server():
			rpc("spawnBlock", num, next_num)
	else:
		move_down()
		
remotesync func spawnBlock(num, next_num) -> void:
	# only server can call this
	if get_tree().get_rpc_sender_id() != 1:
		return
	$CanvasLayer/HUD/HBoxContainer/NextShapePanel/VBoxContainer/Control/Sprite.frame=next_num
	sh=shapes[num].instance()
	$ShapesArea.add_child(sh)
	sh.position=Vector2(320,80)
	active_block=true
	$Timer.start()

func move_left():
	if active_block:
		sh.move_left()

func move_right():
	if active_block:
		sh.move_right()

func move_down():
	if active_block:
		sh.move_down()

func _input(event):
	if sh:
		if Input.is_action_just_pressed("ui_right"):
			move_right()
		if Input.is_action_just_pressed("ui_left"):
			move_left()
		if Input.is_action_just_pressed("ui_down"):
			move_down()
		if Input.is_action_just_pressed("ui_up"):
			sh.rotate_it()


func _on_GameTimer_timeout() -> void:
	if not get_tree().is_network_server():
		return
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
