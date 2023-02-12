extends Node

const DEFAULT_PORT = 44444
const MAX_CLIENTS = 2

var pythonClient = WebSocketClient.new()

var server = null
var client = null

var clients = []

var ipAddress = ""

signal server_created

func _ready() -> void:
	getIPAddress()
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	connectToPythonServer()
	
func _process(delta: float) -> void:
	pythonClient.poll()
	
func getIPAddress() -> void:
	print("Get IP Address")
	var addresses = []
	for ip in IP.get_local_addresses():
		if ip.begins_with("10.") or ip.begins_with("172.16.") or ip.begins_with("192.168."):
			addresses.push_back(ip)
	ipAddress = addresses[0]
	
func reset() -> void:
	if server:
		server.close_connection()
	server = null
	client = null
	
func connectToPythonServer() -> void:
	# Start Python Server
	if OS.has_feature("standalone"):
		OS.execute("server.exe", [], false, [], true)
	else:
		OS.execute("Python Server\\dist\\server.exe", [], false, [], true)
	yield(get_tree().create_timer(0.1), "timeout")
	pythonClient.connect("connection_closed", self, "on_python_server_closed")
	pythonClient.connect("connection_error", self, "on_python_server_connection_error")
	pythonClient.connect("connection_established", self, "on_python_server_connection_established")
	pythonClient.connect("data_received", self, "on_python_server_data_received")
	
	if pythonClient.connect_to_url("127.0.0.1:7890") != OK:
		print("unable to connect")
		set_process(false)
	
func createServer() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)
	emit_signal("server_created")
	print("Server Created Successfully")
	
func joinServer() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ipAddress, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	
func _connected_to_server() -> void:
	print("Successfully Connected To Server")

func _server_disconnected() -> void:
	print("Disconnected From Server")
	
func on_python_server_closed(wasClean:bool) -> void:
	print("Python Server Closed")
	
func on_python_server_connection_error() -> void:
	print("Python Server Connection Error")
	
func on_python_server_connection_established(proto:String) -> void:
	print("Python Server Connection Established")
	
func on_python_server_data_received() -> void:
	var payload = JSON.parse(pythonClient.get_peer(1).get_packet().get_string_from_utf8()).result
	print("Received: %s" %payload)
	
func sendData(message:String) -> void:
	if not pythonClient.get_peer(1).is_connected_to_host():
		print("ERROR: Not Connected To Python Server!")
		return
	print("Sending Event Data: %s" %message)
	pythonClient.get_peer(1).put_packet(message.to_utf8())
