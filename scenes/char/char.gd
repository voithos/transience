extends "res://scripts/flux_entity.gd"

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	add_to_group("char")

func _fixed_process(delta):
	flux_fixed_process(delta)
	react_to_motion_controls(delta)

func _input(event):
	react_to_action_controls(event)