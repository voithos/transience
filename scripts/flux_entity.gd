extends "res://scripts/entity.gd"

# Flux-based entity management. This contains a lot of the logic for the
# player character.

signal flux_changed

export (int) var MAX_FLUX = 100
onready var flux = 0

const FLUX_PER_THROWBACK_STEP = 1 # Arbitrary, for now
const FLUX_GAIN_RATE = .2 # Arbitrary, for now
# TODO: Make delta-throwback based on how long button is held.
const THROWBACK_STEPS = 50

const MAX_THROWBACKS = 256
var throwback_positions = []
var throwback_i = 0
var throwback_count = 0

const THROWBACK_TWEEN_TIME = 0.15
onready var tween_node = get_node("Tween")
var is_animating = false

func _ready():
	throwback_positions.resize(MAX_THROWBACKS)
	tween_node.connect("tween_complete", self, "on_throwback_complete")

func move_entity(motion, dir):
	var remainder = .move_entity(motion, dir)

	# Only heal and cache throwback when we actually move,
	# and do so without collisions.
	if motion.length_squared() and not remainder.length_squared():
		heal_flux(motion.length_squared() * FLUX_GAIN_RATE)
		cache_throwback_position()
	return remainder
	
func heal_flux(amount):
	var previous_flux = flux
	flux = min(flux + amount, MAX_FLUX)

	if flux != previous_flux:
		emit_signal("flux_changed", flux_ratio())

func flux_ratio():
	return flux / MAX_FLUX

func can_throwback(steps):
	var enough_flux = (steps * FLUX_PER_THROWBACK_STEP) <= flux
	var enough_throwback = steps <= throwback_count
	return enough_flux and enough_throwback

# Caches the throwback position in the cyclic throwback array.
func cache_throwback_position():
	throwback_positions[throwback_i] = get_pos()
	throwback_i = (throwback_i + 1) % MAX_THROWBACKS
	throwback_count = min(throwback_count + 1, MAX_THROWBACKS)

func throwback(steps):
	assert(can_throwback(steps))
	flux -= steps * FLUX_PER_THROWBACK_STEP
	emit_signal("flux_changed", flux_ratio())
	
	# GDScript's modulo operator doesn't work on negatives, so "wrap" manually.
	throwback_i -= steps
	if throwback_i < 0:
		throwback_i += MAX_THROWBACKS
	throwback_count -= steps

	tween_node.interpolate_property(self, "transform/pos", get_pos(), throwback_positions[throwback_i], \
			THROWBACK_TWEEN_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween_node.start()
	on_throwback_start()

func on_throwback_start():
	# Disable collisions - e.g. enemy attacks, etc.
	set_layer_mask(0)
	set_collision_mask(0)
	is_animating = true

func on_throwback_complete(object, key):
	# Re-enable collisions.
	set_layer_mask(1)
	set_collision_mask(1)
	is_animating = false

func react_to_motion_controls(delta):
	if is_animating:
		return

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
	if is_animating:
		return

	if event.is_action_pressed("trans_accept"):
		if can_throwback(THROWBACK_STEPS):
			throwback(THROWBACK_STEPS)