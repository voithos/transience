extends Node

func _ready():
	set_process_input(true)
	OS.set_window_fullscreen(true)

func _input(event):
	if event.type == InputEvent.KEY and event.is_pressed() and event.scancode == KEY_ESCAPE:
		get_tree().quit()