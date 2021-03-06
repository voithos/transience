extends "res://scripts/base_scripts/entity.gd"

# Flux-based entity management. This contains a lot of the logic for the
# player character (perhaps the filename is a misnomer...).
# Expects the following child nodes (with the given name):
# - Tween

signal flux_changed

export (int) var MAX_FLUX = 100
onready var flux = MAX_FLUX

const FLUX_PER_THROWBACK_STEP = .8 # Multiplied with THROWBACK_STEPS
const FLUX_GAIN_RATE = 30 # Arbitrary, for now
const THROWBACK_STEPS = 48
const FLUX_PER_ATTACK = 20

onready var throwback_tween_node = get_node("ThrowbackTween")
const MAX_THROWBACKS = 512
var throwback_snapshots = []
var throwback_i = 0 # Index of the next throwback snapshot (not the most-recent one)
var throwback_i_previous = 0 # Previous index used while performing throwback animation
var throwback_count = 0

onready var throwback_particles = get_node("ThrowbackParticles")

const THROWBACK_TWEEN_TIME = 0.4
const THROWBACK_OPACITY = 0.3

const TIME_BEFORE_QUEUEING_NEW_ACTION = 0.3

func _ready():
	throwback_snapshots.resize(MAX_THROWBACKS)
	throwback_particles.set_emitting(false)
	throwback_tween_node.connect("tween_completed", self, "on_throwback_complete")

func flux_physics_process(delta):
	# Flux recovery.
	if current_state == STATE_IDLE or current_state == STATE_MOVE:
		heal_flux(delta * FLUX_GAIN_RATE)

	# Attack slide motion.
	if current_state == STATE_ATTACK:
		slide_in_dir(get_dir())

func move_entity(motion, dir, delta, accel_delay=true):
	var amount_moved = .move_entity(motion, dir, delta, accel_delay)
	var remainder = motion - amount_moved

	# Perform certain operations only when we actually move without collisions, or is "sliding".
	var is_sliding = remainder.x and remainder.y
	if (motion * delta).length_squared() and (not remainder.length_squared() or is_sliding):
		on_actual_move(motion, dir, delta)
	else:
		on_non_actual_move(motion, dir, delta)
	return amount_moved

func on_actual_move(motion, dir, delta):
	cache_throwback_position()

func on_non_actual_move(motion, dir, delta):
	pass

func heal_flux(amount):
	var previous_flux = flux
	flux = min(flux + amount, MAX_FLUX)

	if flux != previous_flux:
		emit_signal("flux_changed", flux_ratio())

func use_flux(amount):
	assert(amount <= flux)
	flux -= amount
	emit_signal("flux_changed", flux_ratio())

func flux_ratio():
	return float(flux) / MAX_FLUX

func can_throwback(steps):
	var enough_flux = (steps * FLUX_PER_THROWBACK_STEP) <= flux
	var enough_throwback = steps <= throwback_count
	return enough_flux and enough_throwback

func is_in_throwback():
	return current_state == STATE_THROWBACK

# Caches the throwback position in the cyclic throwback array.
func cache_throwback_position():
	if not can_accept_input():
		return
	var snapshot = {
		position = position,
		dir = current_dir,
	}
	throwback_snapshots[throwback_i] = snapshot
	throwback_i = (throwback_i + 1) % MAX_THROWBACKS
	throwback_count = min(throwback_count + 1, MAX_THROWBACKS)

func throwback(steps):
	assert(can_throwback(steps))
	use_flux(steps * FLUX_PER_THROWBACK_STEP)
	
	# Cache previous values in order to use them in the step function.
	# throwback_i is the index of the next throwback value (so it can be Nil),
	# so we subtract one.
	throwback_i_previous = int(util.modulo(throwback_i - 1, MAX_THROWBACKS))

	# Set the new throwback index that we will animate towards.
	throwback_i = int(util.modulo(throwback_i - steps, MAX_THROWBACKS))
	throwback_count -= steps

	throwback_tween_node.interpolate_method(self, "on_throwback_step", 0, steps, \
			THROWBACK_TWEEN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN)
	throwback_tween_node.start()
	on_throwback_start()

func on_throwback_start():
	play_sample("throwback")

	# Disable collisions - e.g. enemy attacks, etc.
	set_collision_layer_bit(0, 0)
	set_collision_mask_bit(0, 0)

	enable_throwback_visuals()
	change_state(STATE_THROWBACK)

func enable_throwback_visuals():
	throwback_particles.set_emitting(true)
	sprite.modulate = Color(1, 1, 1, THROWBACK_OPACITY)

func disable_throwback_visuals():
	throwback_particles.set_emitting(false)
	sprite.modulate = Color(1, 1, 1, 1)

func on_throwback_step(offset):
	var progress = util.modulo(throwback_i_previous - offset, MAX_THROWBACKS)
	# i and j are the two indices that have relevant positions for the animation.
	var i = int(progress)
	var j = int(util.modulo(i + 1, MAX_THROWBACKS))
	var fraction = progress - i
	
	var snapshot_i = throwback_snapshots[i]
	var new_pos = snapshot_i.position
	# Account for any fractional interpolation.
	if fraction > 0:
		new_pos = new_pos.linear_interpolate(throwback_snapshots[j].position, fraction)
	# TODO: Change this to the running animation.
	play_dir_animation(snapshot_i.dir, "idle")
	position = new_pos

func on_throwback_complete(object, key):
	# Re-enable collisions.
	set_collision_layer_bit(0, 1)
	set_collision_mask_bit(0, 1)

	disable_throwback_visuals()
	change_state(STATE_IDLE)

	# Handle any queued action.
	handle_next_action_if_needed()

func can_attack():
	return FLUX_PER_ATTACK <= flux

func attack():
	assert(can_attack())
	use_flux(FLUX_PER_ATTACK)
	.attack()

func on_attack_triggered():
	# TODO: Make this play earlier so that the sound syncs up.
	play_sample("slice")
	.on_attack_triggered()

func on_damaged(damage, attacked_direction):
	play_sample("damaged")
	audio_alt.trigger_pain_effect()
	camera_controller.shake_light()
	.on_damaged(damage, attacked_direction)

func react_to_motion_controls(delta):
	if cutscene.is_in_cutscene: return
	if not can_accept_input(): return

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

	motion = motion.normalized() * SPEED
	move_entity(motion, dir, delta)

func react_to_action_controls(event):
	if cutscene.is_in_cutscene: return

	var action = null
	for trans_action in ["trans_accept", "trans_attack", "trans_dodge"]:
		if event.is_action_pressed(trans_action):
			action = trans_action

	if action:
		if can_accept_input():
			immediately_run_action(action)
			return
		
		# If we reach here, it means we're currently in an animation.
		# Check for the amount of time left before we can trigger a new action.
		var time_left = animation_player.current_animation_length - animation_player.current_animation_position
		# Special case for tween-based states.
		if is_in_throwback():
			time_left = throwback_tween_node.get_runtime() - throwback_tween_node.tell()
		if time_left < TIME_BEFORE_QUEUEING_NEW_ACTION:
			set_next_action_if_unset(action)

		# Otherwise, just drop the input.

func immediately_run_action(action):
	if action == "trans_dodge":
		if can_throwback(THROWBACK_STEPS):
			throwback(THROWBACK_STEPS)
	if action == "trans_attack":
		if can_attack():
			attack()

func handle_next_action(action):
	# Run the queued action.
	immediately_run_action(action)
	.handle_next_action(action)