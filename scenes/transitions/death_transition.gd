extends CanvasLayer

# The "death" transition scene, which is created when the player dies.

signal resurrection_completed

const flame_scene = preload("res://scenes/transitions/death_flame.tscn")
const explosion_scene = preload("res://scenes/transitions/death_explosion.tscn")

# Animation transition times, in seconds.
const GRAY_TWEEN_TIME = 2
const FLAME_TWEEN_TIME = 2

onready var camera_controller = get_node("/root/camera_controller")

var tween
onready var flame = get_node("Flame")
var flame2
onready var filter = get_node("GrayscaleFilter")
onready var filter_rect = get_node("GrayscaleFilter/GrayscaleRect")

const STAGE_GRAY = 'gray'
const STAGE_FLAME = 'flame'
const STAGE_FEEDBACK = 'feedback'
const STAGE_FEEDBACK_COMPLETE = 'feedbackcomplete'
const STAGE_COMPLETE = 'complete'
var stage = STAGE_GRAY

const RESURRECTION_STEP = 0.07
const RESURRECTION_DECAY = 0.003
const RESURRECTION_FLAME_MULTIPLIER = 3
var resurrection_progress = 0
var resurrection_tween_progress = 0

# Initial material values, used for lerping.
var flame_initial_lifetime
var flame_initial_velocity
var flame_initial_radius
var flame_initial_scale

var explosion_initial_velocity = 100

func _ready():
	tween = Tween.new()
	add_child(tween)
	tween.connect("tween_completed", self, "on_tween_complete")

	# Create a duplicate particle system for the resurrection feedback
	# animation. For details on why this is necessary, see update_resurrection_progress_effects.
	flame2 = flame_scene.instance()
	add_child(flame2)
	flame2.modulate.a = 0

	# Reset scene.
	flame.modulate.a = 0
	set_gray_intensity(0)
	set_white_mix(0)

	start_transition()

func _input(event):
	# Only accept progress during feedback.
	if stage != STAGE_FEEDBACK:
		return

	if Input.is_action_just_pressed("trans_accept"):
		progress_resurrection()

func _process(delta):
	# Only process resurrection progress during feedback.
	if stage != STAGE_FEEDBACK and stage != STAGE_FEEDBACK_COMPLETE:
		return

	update_resurrection_progress_effects(delta)

func _physics_process(delta):
	# Only reduce progress during feedback.
	if stage != STAGE_FEEDBACK:
		return

	regress_resurrection()

func progress_resurrection():
	adjust_resurrection_progress_by(RESURRECTION_STEP)
	emit_explosion()
	camera_controller.shake(
		lerp(camera_controller.SHAKE_LIGHT_DURATION / 2, camera_controller.SHAKE_LIGHT_DURATION * 2, resurrection_tween_progress),
		lerp(camera_controller.SHAKE_LIGHT_FREQUENCY / 2, camera_controller.SHAKE_LIGHT_FREQUENCY * 2 , resurrection_tween_progress),
		lerp(camera_controller.SHAKE_LIGHT_AMPLITUDE / 2, camera_controller.SHAKE_LIGHT_AMPLITUDE * 2, resurrection_tween_progress)
	)

func regress_resurrection():
	adjust_resurrection_progress_by(-RESURRECTION_DECAY)

func adjust_resurrection_progress_by(v):
	var new_progress = min(max(0, resurrection_progress + v), 1.0)
	if new_progress != resurrection_progress:
		resurrection_progress = new_progress

		# Resurrection complete!
		if resurrection_progress == 1.0:
			stage = STAGE_FEEDBACK_COMPLETE

func emit_explosion():
	var explosion = explosion_scene.instance()
	add_child_below_node(filter, explosion)
	explosion.one_shot = true
	explosion.emitting = true
	explosion.process_material.initial_velocity = lerp(
			explosion_initial_velocity, explosion_initial_velocity * RESURRECTION_FLAME_MULTIPLIER * 2, resurrection_tween_progress)

# Called by the tween to fluidly update the effects of resurrection progress.
func update_resurrection_progress_effects(delta):
	var v = lerp(resurrection_tween_progress, resurrection_progress, 2.5 * delta)
	# Need to save this so that it can "restart" the animation later.
	resurrection_tween_progress = v

	# First half of transition fade out from gray.
	set_gray_intensity(max(0, 1.0 - (v * 2)))
	# Second half of transition fades into white.
	set_white_mix(max(0, v - 0.5) * 2)
	
	# Adjust flame properties.
	for particles in [flame, flame2]:
		# Unfortunately, we can't adjust the particle amount without causing the particle
		# system to reset, so instead we fake it by having a duplicate flame particle system
		# and slowly showing that instead.
		particles.lifetime = lerp(
				flame_initial_lifetime, flame_initial_lifetime * RESURRECTION_FLAME_MULTIPLIER / 2, v)
		particles.process_material.initial_velocity = lerp(
				flame_initial_velocity, flame_initial_velocity * RESURRECTION_FLAME_MULTIPLIER, v)
		particles.process_material.emission_sphere_radius = lerp(
				flame_initial_radius, flame_initial_radius * RESURRECTION_FLAME_MULTIPLIER, v)
		particles.process_material.scale = lerp(
				flame_initial_scale, flame_initial_scale * RESURRECTION_FLAME_MULTIPLIER / 2, v)
		

	# Apply the opacity modulation for the duplicate flame only.
	flame2.modulate.a = v

	# Check for completion condition.
	if 1.0 - resurrection_tween_progress < 0.001:
		stage = STAGE_COMPLETE
		emit_signal("resurrection_completed")

func set_gray_intensity(v):
	filter_rect.material.set_shader_param("gray_intensity", v)

func set_white_mix(v):
	filter_rect.material.set_shader_param("white_mix", v)

func start_transition():
	tween.interpolate_method(self, "set_gray_intensity", 0, 1.0, GRAY_TWEEN_TIME, \
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func on_tween_complete(object, key):
	if stage == STAGE_GRAY:
		stage = STAGE_FLAME
		tween.interpolate_property(flame, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), FLAME_TWEEN_TIME, \
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	elif stage == STAGE_FLAME:
		stage = STAGE_FEEDBACK
		flame_initial_lifetime = flame.lifetime
		flame_initial_velocity = flame.process_material.initial_velocity
		flame_initial_radius = flame.process_material.emission_sphere_radius
		flame_initial_scale = flame.process_material.scale