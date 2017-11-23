extends KinematicBody2D

# Common entity (player, enemy) management.

signal health_changed
signal died

export (int) var MAX_HEALTH = 100
export (int) var SPEED = 100 # Pixels/second
onready var health = MAX_HEALTH

onready var animation_player = get_node("AnimationPlayer")

const STATE_IDLE = 0
const STATE_MOVE = 1
const STATE_ATTACK = 2
const STATE_DYING = 3
const STATE_DEAD = 4

var current_state = STATE_IDLE
var previous_state = STATE_IDLE

# Valid dirs are "up", "down", "left", "right", and null, denoting idleness.
var current_dir = null
var previous_dir = null

func change_state(new_state):
	if new_state == current_state:
		return
	print("State changed to ", new_state)
	previous_state = current_state
	current_state = new_state

# Moves the entity in a given direction.
#   motion: A Vector2() containing x/y motion.
#   dir: One of "up", "down", "left", "right", used for animation.
#        Can also be null to designate no direction (idle)
func move_entity(motion, dir):
	previous_dir = current_dir
	current_dir = dir

	if dir and dir != previous_dir:
		change_state(STATE_MOVE)
		# TODO: Change this to *_move.
		animation_player.play(dir + "_idle")
	else:
		change_state(STATE_IDLE)
		if previous_dir:
			animation_player.play(previous_dir + "_idle")

	motion = move(motion)

	# Make character slide nicely through the world
	var slide_attempts = 4
	while is_colliding() and slide_attempts > 0:
		motion = get_collision_normal().slide(motion)
		motion = move(motion)
		slide_attempts -= 1

func take_damage(damage):
	# TODO: Add state management so that take_damage/heal are no-ops
	# when entity is dead.
	health -= damage
	if health <= 0:
		health = 0
		emit_signal("died")
	else:
		emit_signal("health_changed", health)

func heal(amount):
	var previous_health = health
	health = min(health + amount, MAX_HEALTH)
	
	if health != previous_health:
		emit_signal("health_changed", health)

func health_ratio():
	return health / MAX_HEALTH
