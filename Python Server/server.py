import websockets
import asyncio
from pylsl import StreamInfo, StreamOutlet
import sys, os
import logging
from datetime import datetime

# Create Logger
DEBUG_FOLDER = "DEBUG_LOGS"
if not os.path.exists(DEBUG_FOLDER):
    os.mkdir(DEBUG_FOLDER)
logName = "debug_{}.txt".format(datetime.now().strftime("%Y-%m-%d_%H%M%S"))
logging.basicConfig(filename=os.path.join(DEBUG_FOLDER, logName),
                    filemode='a',
                    format='[%(asctime)s.%(msecs)d] [%(name)25s] [%(levelname)8s] %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                    level=logging.DEBUG)

LOGGER = logging.getLogger(__name__)

# Connect To Oxysoft
info = StreamInfo("Godot Stream", "Markers", 1, 0, "string", "myuniqueId123")
oxysoft = StreamOutlet(info)
LOGGER.info("Successfully Created Oxysoft Object")

# Server data
PORT = 7890
LOGGER.info("Server listening on Port " + str(PORT))

# A set of connected ws clients
connected = set()

async def handler(message):
    if message == "STOP_SERVER":
        await stopServer()
        sys.exit()
        return
    try:
        oxysoft.push_sample([message])
        LOGGER.info("Sending Oxysoft Event: {}".format(message))
    except Exception as e:
        LOGGER.info(e)

async def stopServer():
    loop = asyncio.get_event_loop()
    LOGGER.info("Stopping Server!")
    loop.stop()

# The main behavior function for this server
async def echo(websocket, path):
    # Store a copy of the connected client
    connected.add(websocket)
    # Handle incoming messages
    try:
        async for message in websocket:
            LOGGER.info("Received message from client: {}".format(message.decode("utf-8")))
            await handler(message.decode("utf-8"))
    # Handle disconnecting clients 
    except websockets.exceptions.ConnectionClosed as e:
        LOGGER.info("A client just disconnected")
    except KeyboardInterrupt as e:
        LOGGER.info("Ctrl-C Pressed")
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
    LOGGER.info("OUTER LOOP CTRL - C")
    loop.stop()
    pass