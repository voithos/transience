extends KinematicBody2D

# Common entity (player, enemy) management.
# Expects the following child nodes (with the given name):
# - AnimationPlayer
# - Sprite

signal health_changed
signal died

export (int) var MAX_HEALTH = 100
export (int) var SPEED = 120 # Pixels/second
onready var health = MAX_HEALTH

# Nodes common to all entities.
onready var sprite = get_node("Sprite")
onready var hitbox = get_node("Hitbox")
onready var animation_player = get_node("AnimationPlayer")
onready var sample_player = get_node("SamplePlayer")
var previous_animation = null

const STATE_IDLE = "IDLE"
const STATE_MOVE = "MOVE"
const STATE_THROWBACK = "THROWBACK"
const STATE_ATTACK = "ATTACK"
const STATE_DYING = "DYING"
const STATE_DEAD = "DEAD"

var current_state = STATE_IDLE
var previous_state = STATE_IDLE
var next_state = null

# Valid dirs are "up", "down", "left", "right", and null, denoting idleness.
var current_dir = null
var previous_dir = null

func _ready():
	connect("died", self, "on_died")
	animation_player.connect("finished", self, "on_animation_finished")

func on_animation_finished():
	if next_state:
		change_state(next_state)
		next_state = null

	if previous_animation.ends_with("attack"):
		on_attack_finished()

func play_animation(animation):
	previous_animation = animation
	animation_player.play(animation)

func change_state(new_state):
	if new_state == current_state:
		return false
	previous_state = current_state
	current_state = new_state
	return true

func can_accept_input():
	return current_state == STATE_IDLE or current_state == STATE_MOVE

# Moves the entity in a given direction, and returns how much motion
# remained before collision (if motion was completely successful, returns (0, 0)).
#   motion: A Vector2() containing x/y motion.
#   dir: One of "up", "down", "left", "right", used for animation.
#        Can also be null to designate no direction (idle)
func move_entity(motion, dir):
	if dir != current_dir:
		previous_dir = current_dir
		current_dir = dir

	if dir and dir != previous_dir:
		change_state(STATE_MOVE)
		# TODO: Change this to *_move.
		play_animation(dir + "_idle")
	else:
		change_state(STATE_IDLE)
		if previous_dir:
			play_animation(previous_dir + "_idle")

	var remainder = move(motion)
	motion = remainder

	# Make character slide nicely through the world
	var slide_attempts = 4
	while is_colliding() and slide_attempts > 0:
		motion = get_collision_normal().slide(motion)
		motion = move(motion)
		slide_attempts -= 1

	return remainder

# Returns the most recent direction that the entity is facing.
# This is guaranteed to return an actual direction, not null.
func get_dir():
	if current_dir != null:
		return current_dir
	if previous_dir != null:
		return previous_dir

	# Both dirs are null; must be a newly created entity.
	var animation = animation_player.get_current_animation()
	var separator = animation.find("_")
	if separator != -1:
		var dir = animation.left(separator)
		if dir in ["up", "down", "left", "right"]:
			return dir

	# Default.
	return "down"

func attack():
	change_state(STATE_ATTACK)
	next_state = STATE_IDLE
	play_animation(get_dir() + "_attack")

# Triggered by AnimationPlayer on the appropriate "attack" frame.
func on_attack_triggered():
	pass

func on_attack_finished():
	play_animation(get_dir() + "_idle")

func take_damage(damage):
	# TODO: Add state management so that take_damage/heal are no-ops
	# when entity is dead.
	health -= damage
	if health <= 0:
		health = 0
		emit_signal("died")
	else:
		emit_signal("health_changed", health_ratio())

func on_died():
	var successful = change_state(STATE_DYING)
	if successful:
		play_animation("die")

func heal(amount):
	var previous_health = health
	health = min(health + amount, MAX_HEALTH)
	
	if health != previous_health:
		emit_signal("health_changed", health_ratio())

func health_ratio():
	return health / MAX_HEALTH
