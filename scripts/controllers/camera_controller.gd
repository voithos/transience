extends Node

# A controller that makes the camera globally accessible
# and animatable.

var camera

# Predefined shake forms.
const SHAKE_LIGHT_DURATION = 0.2
const SHAKE_LIGHT_FREQUENCY = 30
const SHAKE_LIGHT_AMPLITUDE = 4

func set_camera(camera):
	self.camera = camera

func shake_light():
	camera.shake(SHAKE_LIGHT_DURATION, SHAKE_LIGHT_FREQUENCY, SHAKE_LIGHT_AMPLITUDE)