extends Node

func _ready():
	set_process_input(true)
	if not OS.is_debug_build():
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_size(Vector2(800, 600))

func _input(event):
	if event.type == InputEvent.KEY and event.is_pressed() and event.scancode == KEY_ESCAPE:
		get_tree().quit()