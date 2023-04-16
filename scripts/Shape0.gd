extends Node2D
class_name Shape0

var rotate_position=0
var is_fixed=false
var rotation_matrix=[]
var create_position:Vector2=Vector2.ZERO

signal freezeShape

func _ready() -> void:
	connect("freezeShape", self, "_on_freeze_shape_signal")

func draw_shape():
	var ind=0
	for ch in get_children():
		ch.position=rotation_matrix[rotate_position][ind]
		ind+=1

func _physics_process(delta: float) -> void:
	# for combo counting
	var count = 0
	for ch in get_children():
		if not ch.is_active:
			count += 1
	if count == get_child_count():
		# have finish inactivating
		Globals.emit_signal("resetComboCount")

func rotate_it():
	if not is_fixed:
		rotate_shape()

func rotate_shape():
	var can_rotate=true
	var child_pos=0
	for ch in get_children():
		if can_rotate:
			can_rotate=ch.can_rotate(rotation_matrix[rotate_position][child_pos])
		child_pos+=1
	if can_rotate:
		var j=0
		for ch in get_children():
			ch.position=rotation_matrix[rotate_position][j]
			j+=1
		rotate_position=rotate_position+1 if rotate_position<3 else 0

func inactivate_it():
	if position==create_position:
		get_tree().reload_current_scene()
	for ch in get_children():
		ch.inactivate_it()

func move_left():
	if not is_fixed:
		for ch in get_children():
			if not ch.can_move_left():
				return
		if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			position.x-=80
		elif Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE and get_tree().is_network_server():
			# collab mode client will wait for server to send the pos info
			position.x-=80
		else:
			pass
		if Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE and get_tree().is_network_server():
			# client syncs left right
			var posInfo = []
			for ch in get_children():
				posInfo.append(ch.global_position)
			rpc("syncShapePos", posInfo, global_position)

func move_right():
	if not is_fixed:
		for ch in get_children():
			if not ch.can_move_right():
				return
		if Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
			position.x+=80
		elif Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE and get_tree().is_network_server():
			# collab mode client will wait for server to send the pos info
			position.x+=80
		else:
			pass
		if Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE and get_tree().is_network_server():
			# client syncs left right
			var posInfo = []
			for ch in get_children():
				posInfo.append(ch.global_position)
			rpc("syncShapePos", posInfo, global_position)

func move_down():
	if not create_position:
		create_position=position
	if not is_fixed:
		for ch in get_children():
			if not ch.can_move_down():
				print("create position: %s e position: %s"%[create_position,position])
				if create_position==position:
					# clear board instead of restarting game
					#Globals.restart_game()
					if Globals.currentGameType == Globals.GAME_TYPE.COLLABORATIVE and get_tree().is_network_server():
						Globals.rpc("clearBoard")
					elif Globals.currentGameType == Globals.GAME_TYPE.INDIVIDUAL:
						Globals.clearBoard()
				is_fixed=true
				return
		position.y+=80
		
func _on_freeze_shape_signal() -> void:
	if not get_tree().is_network_server():
		return
	var posArray = []
	for ch in get_children():
		posArray.append(ch.global_position)
	rpc("syncShapeFreeze", posArray)

remote func syncShapeFreeze(pos):
	if get_tree().get_rpc_sender_id() != 1:
		return
	is_fixed = true
	var j=0
	for ch in get_children():
		ch.global_position=pos[j]
		j+=1
		
remote func syncShapePos(pos, parentPos):
	# rpc from server to tell client pos info
	if get_tree().get_rpc_sender_id() != 1:
		return
	var j=0
	global_position = parentPos
	for ch in get_children():
		ch.global_position=pos[j]
		j+=1
	
	
