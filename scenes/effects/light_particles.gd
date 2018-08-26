extends Particles2D

onready var camera_controller = get_node("/root/camera_controller")

func _process(delta):
	# Simply follow the camera.
	self.global_position = camera_controller.camera.global_position