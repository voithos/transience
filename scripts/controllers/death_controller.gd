extends Node

# A controller that instantiates the death transition
# and processes subsequent behavior.

const death_transition_scene = preload("res://scenes/transitions/death_transition.tscn")

func _ready():
	pass

func show_death_transition():
	var nodes = get_tree().get_nodes_in_group("level")
	assert(nodes.size() == 1)
	var level = nodes[0]
	
	var transition = death_transition_scene.instance()
	level.add_child(transition)
	transition.connect("resurrection_completed", self, "on_resurrection_complete")

func on_resurrection_complete():
	print('resurrection complete')