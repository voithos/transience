extends Node

# A controller that makes the current level globally accessible.

var level

func set_level(level):
	self.level = level

func get_navigation():
	return level.get_node("Navigation2D")