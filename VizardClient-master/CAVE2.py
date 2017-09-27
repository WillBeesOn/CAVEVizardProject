#!/usr/bin/python
import websocket
import thread
import time
import threading
import viz
import vizshape
import urllib
import viztask
import socket
import win32gui
import win32con

#Start the Vizard Environment 
viz.go()
#Enable full screen anti-aliasing (FSAA) to smooth edges
refresh_rate = viz.getOption('viz.monitor.refresh_rate',type=int)
print "Refresh rate: "
print refresh_rate

#Piazza Demo
#piazza = viz.addChild('piazza.osgb')

#viz.MainView.move([0,0,0])

viz.WINDOW_NORMALIZED

#Sets vizard window to maximize
win32gui.ShowWindow(viz.window.getHandle(), win32con.SW_MAXIMIZE)
#viz.window.setSize(800,600)

#Create a Sphere in the Vizard World
sphere = vizshape.addSphere(radius=1000.0, slices=2300)
sphere.setPosition([0,0,0])

s = socket.socket(
    socket.AF_INET, socket.SOCK_STREAM)

x = 0
y = 0
z = 0
fov = 40             #vizard default fov is 40
ZOOM_SCALE = 0.05    #0.25
ZOOM_RATE = 0.001
ZOOM_SIZE = 1
ZOOM_LOWER_BOUND = 10.0
ZOOM_UPPER_BOUND = 100.0

#Add a sphere to scene as pointer, representing iPad pointing
pointer = vizshape.addSphere(radius=0.05)
pointer.setPosition(0, 0, 2)

'''
line = viz.MainWindow.screenToWorld(viz.mouse.getPosition())
print line.begin
print line.end
'''

#Set Up the Video Texture on the Sphere
#myVideo = viz.addVideo('Jambo6.mp4')
myImage = viz.addTexture('resource/ladybug_image1.png')
sphere.texture(myImage)
sphere.disable(viz.CULL_FACE) 
sphere.disable(viz.LIGHTING)

#Add These Lines for a Video 
#myVideo.play() 
#myVideo.loop()

viz.fov(45.0)

#Mouse Movement
def onMouseMove(m):
	print e.getPosition()
	
#Zoom Functions
def zoomView(num):
	viz.fov(num)

#Websocket Functionsz
def on_message(ws, message):
	global x
	global y
	global messagePrefix

	print message
	message = message.split()
	messagePrefix = message.pop()
	
	if messagePrefix == "z":
		viz.fov(float(message.pop()))
	elif messagePrefix == "p":
		
		a = float(message.pop())
		b = float(message.pop())
		print a
		print b
		vector3 = viz.MainWindow.screenToWorld([a, b])
		
		#takes a screenshot of window
		#viz.window.screenCapture('test/test.bmp')
		
		pointer.setPosition((vector3.end[0]/vector3.length)*2, ((vector3.end[1]/vector3.length)*2)+1.82, (vector3.end[2]/vector3.length)*2)

		#prints window dimensions
		#print(viz.MainWindow.getSize(viz.WINDOW_ORTHO))
		
	else:
		x = -float(messagePrefix)
		y = -float(message.pop())
		viz.MainView.setEuler(x, y, z)
		
def on_error(ws, error):
    print error

def on_close(ws):
	print "### closed ###"

def on_open(ws):
	def run(*args):
		for i in range(60000):
			time.sleep(5)
			dimension = viz.MainWindow.getSize(viz.WINDOW_ORTHO)
			dimension = str(dimension[0]) + " " + str(dimension[1])
			ws.send(dimension)
		time.sleep(1)
		ws.close()
		print "thread terminating..."
	thread.start_new_thread(run, ())

def functionWebSocket():
	websocket.enableTrace(True)
	ws = websocket.WebSocketApp("ws://localhost:8080/VizardServer/DataPointServer/0",
							on_message = on_message,
							on_error = on_error,
							on_close = on_close)
							
	
	ws.on_open = on_open
	ws.run_forever()

if __name__ == "__main__":
	download_thread = threading.Thread(target=functionWebSocket)
	download_thread.start()