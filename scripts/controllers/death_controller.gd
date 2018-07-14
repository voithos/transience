extends Node

# A controller that instantiates the death transition
# and processes subsequent behavior.

const death_transition_scene = preload("res://scenes/transitions/death_transition.tscn")

onready var level_controller = get_node("/root/level_controller")

func show_death_transition():
	var transition = death_transition_scene.instance()
	level_controller.level.add_child(transition)
	transition.connect("resurrection_completed", self, "on_resurrection_complete")

func on_resurrection_complete():
	# TODO: Actually resurrect.
	print('resurrection complete')