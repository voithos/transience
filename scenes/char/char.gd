extends "res://scripts/flux_entity.gd"

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	add_to_group("char")

func _fixed_process(delta):
	react_to_motion_controls(delta)

func _input(event):
	react_to_action_controls(event)

func react_to_motion_controls(delta):
	var motion = Vector2()
	var dir = null
	
	if Input.is_action_pressed("ui_up"):
		motion.y -= 1
		dir = "up"
	if Input.is_action_pressed("ui_down"):
		motion.y += 1
		dir = "down"
	if Input.is_action_pressed("ui_left"):
		motion.x -= 1
		dir = "left"
	if Input.is_action_pressed("ui_right"):
		motion.x += 1
		dir = "right"

	motion = motion.normalized() * SPEED * delta
	move_entity(motion, dir)

func react_to_action_controls(event):
	if event.is_action_pressed("trans_accept"):
		if can_throwback(THROWBACK_STEPS):
			throwback(THROWBACK_STEPS)