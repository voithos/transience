extends Node

const DEBUG_WINDOW_SIZE = Vector2(800, 600)
var is_paused = false

func _ready():
	set_process_input(true)
	set_pause_mode(PAUSE_MODE_PROCESS) # Never pause this node.
	if not OS.is_debug_build():
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_size(DEBUG_WINDOW_SIZE)

func _input(event):
	if event.type == InputEvent.KEY and event.is_pressed() and event.scancode == KEY_ESCAPE:
		get_tree().quit()

	if OS.is_debug_build():
		if event.type == InputEvent.KEY and event.is_pressed() and event.scancode == KEY_SPACE:
			is_paused = not is_paused
			get_tree().set_pause(is_paused)