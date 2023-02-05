extends Node

const DEFAULT_PORT = 44444
const MAX_CLIENTS = 2

var server = null
var client = null

var clients = []

var ipAddress = ""

signal server_created

func _ready() -> void:
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168"):
			ipAddress = ip
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func reset() -> void:
	if server:
		server.close_connection()
	server = null
	client = null
	
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
