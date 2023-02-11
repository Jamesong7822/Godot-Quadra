import websockets
import asyncio
from pylsl import StreamInfo, StreamOutlet
import sys

# Connect To Oxysoft
info = StreamInfo("Godot Stream", "Events", 1, 0, "string", "myuniqueId123")
oxysoft = StreamOutlet(info)
print("Successfully Created Oxysoft Object")

# Server data
PORT = 7890
print("Server listening on Port " + str(PORT))

# A set of connected ws clients
connected = set()

def handler(message):
    try:
        oxysoft.push_sample([message])
    except Exception as e:
        print(e)

# The main behavior function for this server
async def echo(websocket, path):
    print("A client just connected")
    # Store a copy of the connected client
    connected.add(websocket)
    # Handle incoming messages
    try:
        async for message in websocket:
            print("Received message from client: {}".format(message.decode("utf-8")))
            handler(message.decode("utf-8"))
    # Handle disconnecting clients 
    except websockets.exceptions.ConnectionClosed as e:
        print("A client just disconnected")
    except KeyboardInterrupt as e:
        print("Ctrl-C Pressed")
        loop.stop()
        sys.exit()
    finally:
        connected.remove(websocket)

loop = asyncio.get_event_loop()
try:
    start_server = websockets.serve(echo, "localhost", PORT)
    loop.run_until_complete(start_server)
    loop.run_forever()
except KeyboardInterrupt:
    print("OUTER LOOP CTRL - C")
    loop.stop()
    pass