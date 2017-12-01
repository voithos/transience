extends "res://scripts/enemy.gd"

func _ready():
	set_process(true)

func _process(delta):
	enemy_process(delta)

func get_attack_range():
	# TODO: Adjust this
	return 24

func get_attack_range_buffer():
	# TODO: Adjust this
	return 0

func get_attack_probability():
	# TODO: Adjust this
	return 1