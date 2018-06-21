extends Node

# Common handling of cutscene state and logic.
# This script is autoloaded and individual nodes can refer
# to it when making decisions about accepting input, for example.

signal cutscene_started
signal cutscene_ended

var is_in_cutscene = false

func _ready():
	pass

func start_cutscene():
	assert(not is_in_cutscene)
	is_in_cutscene = true
	emit_signal("cutscene_started")
	
func end_cutscene():
	assert(is_in_cutscene)
	is_in_cutscene = false
	emit_signal("cutscene_ended")