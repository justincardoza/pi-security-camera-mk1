# This file is part of the Raspberry Pi security camera project by Justin Cardoza.
# It's distributed under a CC BY-NC-SA license: https://creativecommons.org/licenses/by-nc-sa/4.0/
# See the original repository for more information: https://github.com/justincardoza/pi-security-camera-mk1

from threading import Event
from signal import signal, SIGTERM, SIGINT
from picamera2 import Picamera2
from picamera2.encoders import H264Encoder
from picamera2.outputs import PyavOutput


shutdownEvent = Event()

def handleShutdown(signum, frame):
	shutdownEvent.set()

signal(SIGTERM, handleShutdown)
signal(SIGINT, handleShutdown)

print("Creating camera object...")
picam2 = Picamera2()

videoConfig = picam2.create_video_configuration(
	main =  { "size": (1920, 1080), "format": "YUV420" },
	lores = { "size": ( 896, 504) , "format": "YUV420" }
)

print("Configuring camera...")
picam2.configure(videoConfig)

print("Creating encoders...")
mainEncoder  = H264Encoder(repeat = True, iperiod = 15, bitrate = 4*1024*1024)
loresEncoder = H264Encoder(repeat = True, iperiod = 15, bitrate = 500*1024)

print("Creating outputs...")
mainOutput = PyavOutput("rtsp://127.0.0.1:8554/main", format = "rtsp")
loresOutput = PyavOutput("rtsp://127.0.0.1:8554/lores", format = "rtsp")

print("Starting encoder streams...")
picam2.start_recording(mainEncoder,  mainOutput, name = "main")
picam2.start_recording(loresEncoder, loresOutput, name = "lores")

print("Streams started.")
shutdownEvent.wait()

print("Stopping streams and exiting...")
picam2.stop_encoder()
