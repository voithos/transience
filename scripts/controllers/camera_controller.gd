extends Node

# A controller that makes the camera globally accessible
# and animatable.

var camera

# Predefined shake forms.
const SHAKE_LIGHT_DURATION = 0.2
const SHAKE_LIGHT_FREQUENCY = 30
const SHAKE_LIGHT_AMPLITUDE = 4

func _ready():
	call_deferred("configure_nodes")

func configure_nodes():
	var nodes = get_tree().get_nodes_in_group("camera")
	# TODO: Come up with a more consistent way to detect issues without breaking running
	# individual scenes (e.g. F6). Maybe printerr() ?
	assert(nodes.size() == 1)
	camera = nodes[0]

func shake_light():
	shake(SHAKE_LIGHT_DURATION, SHAKE_LIGHT_FREQUENCY, SHAKE_LIGHT_AMPLITUDE)

func shake(duration, frequency, amplitude):
	camera.shake(duration, frequency, amplitude)

func get_camera_pos():
	return camera.global_position