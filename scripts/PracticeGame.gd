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
var colorNum:int=-1
var nextColorNum:int=0
var colours = [Color.gold, Color.royalblue, Color.indianred, Color.yellowgreen, Color.darkorange, Color.darkturquoise, Color.orchid]

func _ready():
	name="Main"
	shapes=[shape1,shape2,shape3,shape4,shape5,shape6,shape7]
	rnd.randomize()
	$CanvasLayer/InstructionsPanel.connect("finished", self, "on_instructions_panel_finished")
	
func _process(delta: float) -> void:
	# Update the game time label
	$CanvasLayer/HUD/HBoxContainer/VBoxContainer/TimePanel.updateTimeRemaining($GameTimer.time_left)

func _on_GameTimer_timeout() -> void:
	print("Practice Game Over!")
	get_tree().change_scene(Globals.endGameScene)

func on_instructions_panel_finished():
	# Call the function via RPC to sync the start of the game
	Globals.initializeGameVariables()
	$Timer.wait_time=Globals.speed
	$Timer.start()
	shapes=[shape1,shape2,shape3,shape4,shape5,shape6,shape7]
	rnd.randomize()
	$GameTimer.wait_time = Globals.practiceTime
	$GameTimer.start()

func _on_Timer_timeout():
	$Timer.wait_time=Globals.speed
	if not active_block:
		num=rnd.randi()%7 if num==-1 else next_num
		next_num=rnd.randi()%7
		colorNum = rnd.randi()%7 if num ==-1 else nextColorNum
		nextColorNum = rnd.randi()%7
		$CanvasLayer/HUD/HBoxContainer/NextShapePanel/VBoxContainer/Control/Sprite.visible = true
		$CanvasLayer/HUD/HBoxContainer/NextShapePanel/VBoxContainer/Control/Sprite.frame=next_num
		$CanvasLayer/HUD/HBoxContainer/NextShapePanel/VBoxContainer/Control/Sprite.modulate = colours[nextColorNum]
		sh=shapes[num].instance()
		$ShapesArea.add_child(sh)
		sh.modulate = colours[colorNum]
		sh.position=Vector2(320,80)
		active_block=true
	else:
		move_down()

func move_left():
	if active_block:
		sh.move_left()

func move_right():
	if active_block:
		sh.move_right()

func move_down():
	if active_block:
		sh.move_down()
		$Timer.start()

func _input(event):
	if sh:
		if Input.is_action_just_pressed("ui_right"):
			move_right()
		if Input.is_action_just_pressed("ui_left"):
			move_left()
		if Input.is_action_pressed("ui_down"):
			move_down()
		if Input.is_action_just_pressed("ui_up"):
			sh.rotate_it()
