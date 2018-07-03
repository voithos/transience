extends Camera2D

# An extended camera that supports shaking.
# Taken and modified from https://godotengine.org/qa/438/camera2d-screen-shake-extension?show=438#q438

var _shaking = false
var _duration = 0.0
var _stopwatch = 0.0
var _period = 0.0
var _amplitude = 0.0
var _shake_trigger_accumulator = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _previous_offset = Vector2(0, 0)

# Predefined shake forms.
const SHAKE_LIGHT_DURATION = 0.2
const SHAKE_LIGHT_FREQUENCY = 30
const SHAKE_LIGHT_AMPLITUDE = 4

func _ready():
	# Make the camera available for retrieval elsewhere.
	add_to_group("camera")

func _input(event):
	if Input.is_action_just_pressed("trans_accept"):
		shake(0.2, 30, 4)

func _process(delta):
	if not _shaking:
		return

	_shake_trigger_accumulator += delta
	# Only shake once per period.
	# This loop usually only runs once on any given frame, but
	# in case there's lag, the calculation will run multiple times and stabilize.
	while _shake_trigger_accumulator >= _period:
		_shake_trigger_accumulator -= _period

		# Intensity starts at full amplitude and decreases linearly.
		var intensity = lerp(_amplitude, 0, _stopwatch / _duration)

		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = rand_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + delta * (new_x - _previous_x))
		var new_y = rand_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + delta * (new_y - _previous_y))
		_previous_x = new_x
		_previous_y = new_y

		# Track how much we've moved the offset, so that we don't interfere with
		# other offset effects.
		var new_offset = Vector2(x_component, y_component)
		offset = offset - _previous_offset + new_offset
		_previous_offset = new_offset
			
	_stopwatch += delta
	if _stopwatch > _duration:
		# Clear our offset once shaking is done.
		offset = offset - _previous_offset
		_shaking = false

# Begin the screenshake effect.
#   duration: The amount of time to shake for, in seconds.
#   frequency: The shake frequency (per second).
#   amplitude: How heavily to shake.
func shake(duration, frequency, amplitude):
	_shaking = true
	_duration = duration
	_stopwatch = 0.0
	_period = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = rand_range(-1.0, 1.0)
	_previous_y = rand_range(-1.0, 1.0)
	
	# Clear the offset by subtracting our previous offset so that we don't interfere with
	# other effects that may be ongoing.
	offset = offset - _previous_offset
	_previous_offset = Vector2(0, 0)