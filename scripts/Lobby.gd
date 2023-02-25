extends Control

var gameScene = preload("res://Main.tscn")

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	Network.connect("server_created", self, "_server_created")
	
	$MarginContainer/CenterContainer/VBoxContainer/IPAddress.text = Network.ipAddress
	
	$MarginContainer/CenterContainer/VBoxContainer/StartGameButton.disabled = true
	
func _player_connected(id) -> void:
	print("Player %s has connected" %id)
	_addPlayer(id)
	Network.clients.append(id)
	
func _player_disconnected(id) -> void:
	print("Player %s has disconnected" %id)
	_removePlayer(id)

func _connected_to_server() -> void:
	print("Connected To Server")
	_addPlayer(get_tree().get_network_unique_id())
	Network.clients.append(get_tree().get_network_unique_id())
	
func _server_created() -> void:
	if get_tree().is_network_server():
		$MarginContainer/CenterContainer/VBoxContainer/StartGameButton.disabled = false
		_addPlayer(get_tree().get_network_unique_id())

remote func _addPlayer(id):
	$MarginContainer/CenterContainer/VBoxContainer/PlayerList.addPlayer(id)
	
func _removePlayer(id):
	$MarginContainer/CenterContainer/VBoxContainer/PlayerList.removePlayer(id)

func _on_CreateServerButton_pressed() -> void:
	#hide()
	Network.createServer()
	$MarginContainer/CenterContainer/VBoxContainer/SelectGameModeButton.disabled=false


func _on_JoinServerButton_pressed() -> void:
	if $MarginContainer/CenterContainer/VBoxContainer/LineEdit.text == "":
		return
	Network.ipAddress = $MarginContainer/CenterContainer/VBoxContainer/LineEdit.text
	Network.joinServer()


func _on_StartGameButton_pressed() -> void:
	if not get_tree().is_network_server():
		return
	print("Server Start Game")
	rpc("startGame")
	
remotesync func startGame() -> void:
	get_tree().change_scene_to(gameScene)

func _on_SelectGameModeButton_toggled(button_pressed: bool) -> void:
	var selectGameModeBtn = $MarginContainer/CenterContainer/VBoxContainer/SelectGameModeButton
	if button_pressed:
		selectGameModeBtn.text = "Collaboration First"
	else:
		selectGameModeBtn.text = "Individual First"
	if get_tree().is_network_server():
		rpc("syncSelectGameModeBtnState", button_pressed)
		Globals.rpc("syncGameMode", button_pressed)
		
remote func syncSelectGameModeBtnState(state: bool) -> void:
	var selectGameModeBtn = $MarginContainer/CenterContainer/VBoxContainer/SelectGameModeButton
	if get_tree().get_rpc_sender_id() == 1:
		if state:
			selectGameModeBtn.text = "Collaboration First"
		else:
			selectGameModeBtn.text = "Individual First"
