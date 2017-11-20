
extends KinematicBody2D

export (int) var SPEED = 160 # Pixels/second

# Sprites
var animation_player

func _ready():
	set_fixed_process(true)
	animation_player = get_node("AnimationPlayer")

func _fixed_process(delta):
	var motion = Vector2()
	
	if Input.is_action_pressed("ui_up"):
		motion.y -= 1
		animation_player.play("up_idle")
	if Input.is_action_pressed("ui_down"):
		motion.y += 1
		animation_player.play("down_idle")
	if Input.is_action_pressed("ui_left"):
		motion.x -= 1
		animation_player.play("left_idle")
	if Input.is_action_pressed("ui_right"):
		motion.x += 1
		animation_player.play("right_idle")
	
	motion = motion.normalized() * SPEED * delta
	motion = move(motion)
	
	# Make character slide nicely through the world
	var slide_attempts = 4
	while is_colliding() and slide_attempts > 0:
		motion = get_collision_normal().slide(motion)
		motion = move(motion)
		slide_attempts -= 1
