extends CanvasLayer

# The "death" transition scene, which is created when the player dies.

signal resurrection_completed

# Animation transition times, in seconds.
const GRAY_TWEEN_TIME = 2
const FLAME_TWEEN_TIME = 2

var tween
onready var particles = get_node("Flame")
onready var filter_rect = get_node("GrayscaleFilter/GrayscaleRect")

const STAGE_GRAY = 'gray'
const STAGE_FLAME = 'flame'
const STAGE_FEEDBACK = 'feedback'
const STAGE_FEEDBACK_COMPLETE = 'feedbackcomplete'
const STAGE_COMPLETE = 'complete'
var stage = STAGE_GRAY

const RESURRECTION_STEP = 0.07
const RESURRECTION_DECAY = 0.003
var resurrection_progress = 0
var resurrection_tween_progress = 0

func _ready():
	tween = Tween.new()
	add_child(tween)
	tween.connect("tween_completed", self, "on_tween_complete")

	particles.modulate = Color(1, 1, 1, 0)
	set_gray_intensity(0)
	set_white_mix(0)

	start_transition()

func _input(event):
	# Only accept progress during feedback.
	if stage != STAGE_FEEDBACK:
		return

	if Input.is_action_just_pressed("trans_accept"):
		adjust_resurrection_progress_by(RESURRECTION_STEP)

func _process(delta):
	# Only process resurrection progress during feedback.
	if stage != STAGE_FEEDBACK and stage != STAGE_FEEDBACK_COMPLETE:
		return

	update_resurrection_progress_effects(delta)

func _physics_process(delta):
	# Only reduce progress during feedback.
	if stage != STAGE_FEEDBACK:
		return

	adjust_resurrection_progress_by(-RESURRECTION_DECAY)

func adjust_resurrection_progress_by(v):
	var new_progress = min(max(0, resurrection_progress + v), 1.0)
	if new_progress != resurrection_progress:
		resurrection_progress = new_progress

		# Resurrection complete!
		if resurrection_progress == 1.0:
			stage = STAGE_FEEDBACK_COMPLETE

# Called by the tween to fluidly update the effects of resurrection progress.
func update_resurrection_progress_effects(delta):
	var v = lerp(resurrection_tween_progress, resurrection_progress, 2.5 * delta)
	# Need to save this so that it can "restart" the animation later.
	resurrection_tween_progress = v

	# First half of transition fade out from gray.
	set_gray_intensity(max(0, 1.0 - (v * 2)))
	# Second half of transition fades into white.
	set_white_mix(max(0, v - 0.5) * 2)
	
	# Check for completion condition.
	if 1.0 - resurrection_tween_progress < 0.001:
		stage = STAGE_COMPLETE

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
		tween.interpolate_property(particles, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), FLAME_TWEEN_TIME, \
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	elif stage == STAGE_FLAME:
		stage = STAGE_FEEDBACK