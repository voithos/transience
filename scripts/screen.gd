extends Node

const DEFAULT_DEBUG_WINDOW_SIZE = Vector2(960, 540)
var is_paused = false

func _ready():
	set_pause_mode(PAUSE_MODE_PROCESS) # Never pause this node.
	if not OS.is_debug_build():
		OS.set_window_fullscreen(true)
	else:
		var size = DEFAULT_DEBUG_WINDOW_SIZE
		var width = ProjectSettings.get_setting("display/window/size/test_width")
		var height = ProjectSettings.get_setting("display/window/size/test_height")

		if width > 0 and height > 0:
			size = Vector2(width, height)
		OS.window_size = size

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()

		if OS.is_debug_build():
			if event.scancode == KEY_SPACE:
				is_paused = not is_paused
				get_tree().set_pause(is_paused)
			if event.scancode == KEY_F11:
				OS.window_fullscreen = not OS.window_fullscreen