extends Particles2D

func _process(delta):
	# Simply follow the camera.
	var nodes = get_tree().get_nodes_in_group("camera")
	if nodes.size() != 0:
		assert(nodes.size() == 1)
		var camera = nodes[0]
		self.global_position = camera.global_position