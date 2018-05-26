extends Node

# Utility script, used from other scripts and nodes.

# Performs modulo with negative wrapping.
# GDScript's modulo operator doesn't work on negatives, so we "wrap" manually.
func modulo(x, y):
	if x < 0:
		x += y
	return fmod(x, y)