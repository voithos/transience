extends KinematicBody2D

# Common entity (player, enemy) management.

signal health_changed
signal died

export (int) var MAX_HEALTH = 100
export (int) var SPEED = 100 # Pixels/second
onready var health = MAX_HEALTH

onready var animation_player = get_node("AnimationPlayer")

const STATE_IDLE = "IDLE"
const STATE_MOVE = "MOVE"
const STATE_ATTACK = "ATTACK"
const STATE_DYING = "DYING"
const STATE_DEAD = "DEAD"

var current_state = STATE_IDLE
var previous_state = STATE_IDLE

# Valid dirs are "up", "down", "left", "right", and null, denoting idleness.
var current_dir = null
var previous_dir = null

func change_state(new_state):
	if new_state == current_state:
		return
	previous_state = current_state
	current_state = new_state

# Moves the entity in a given direction, and returns how much motion
# remained before collision (if motion was completely successful, returns (0, 0)).
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

	var remainder = move(motion)
	motion = remainder

	# Make character slide nicely through the world
	var slide_attempts = 4
	while is_colliding() and slide_attempts > 0:
		motion = get_collision_normal().slide(motion)
		motion = move(motion)
		slide_attempts -= 1

	return remainder

func take_damage(damage):
	# TODO: Add state management so that take_damage/heal are no-ops
	# when entity is dead.
	health -= damage
	if health <= 0:
		health = 0
		emit_signal("died")
	else:
		emit_signal("health_changed", health_ratio())

func heal(amount):
	var previous_health = health
	health = min(health + amount, MAX_HEALTH)
	
	if health != previous_health:
		emit_signal("health_changed", health_ratio())

func health_ratio():
	return health / MAX_HEALTH
