extends CanvasLayer

# Dialog box for in-game speech. Handles animating the text and
# paging. Input speech data can use the '#' character to indicate
# a delay after the previous character.

signal speech_completed

onready var sample_player = get_node("SamplePlayer")
onready var timer = get_node("Timer")
onready var label = get_node("RichTextLabel")

const TIMER_NORMAL = 0.035
const TIMER_DELAY = 0.15  # Extra delay added by a single delay char.
const DELAY_CHAR = '#'

# The speech data as an array of strings.
# Enter something in the default array to test out the speech dialog.
var speech_data = []
var page = 0
# A dictionary of (character position, delay) pairs.
var char_delays = {}

func _ready():
	timer.connect("timeout", self, "on_timeout")
	start_if_ready()

func _input(event):
	# TODO: Also react to the other buttons as well.
	if event.is_action_pressed("trans_accept"):
		if not is_page_complete():
			# Complete the page immediately.
			label.visible_characters = label.get_total_character_count()
		elif page < len(speech_data) - 1:
			# Move on to the next page.
			page += 1
			start_current_page()
		else:
			# Close the dialog.
			# First mark the event so that other nodes know not to re-open the dialog
			# due to this very same input.
			event.set_meta("consumed_by", "speech")
			emit_signal("speech_completed")
			queue_free()

func init(speech_data):
	self.speech_data = speech_data
	start_if_ready()

func start_if_ready():
	if speech_data:
		start_current_page()

func start_current_page():
	# Reset timer speed in case we transitioned in the middle
	# of a slow character.
	timer.wait_time = TIMER_NORMAL
	timer.start()
	
	# Process page speech text.
	var speech_text = speech_data[page]
	speech_text = speech_text.strip_edges()
	
	collect_char_delays(speech_text)
	speech_text = speech_text.replace(DELAY_CHAR, '')
	
	speech_text = "[center]" + speech_text + "[/center]"
	label.bbcode_text = speech_text
	label.visible_characters = 0

func collect_char_delays(speech_text):
	char_delays.clear()

	# Collect character delays based on '#' characters.
	# Attempts to ignore bbcode tags.
	var is_bbcode = false
	# Add an offset to account for '#' characters as well as '\n'.
	var index_offset = 0
	for i in range(len(speech_text)):
		var c = speech_text[i]
		if is_bbcode:
			if c == ']':
				is_bbcode = false
			index_offset += 1
		else:
			if c == '[':
				is_bbcode = true
				index_offset += 1
			elif c == '\n':
				index_offset += 1
			elif c == DELAY_CHAR:
				# This pos is used with label.visible_characters, which is
				# effectively 1-based, but we don't add 1 to the index
				# because the relevant char is actually the previous character
				# already.
				
				# TODO: Remove final char delays, as they don't make sense and
				# cause an extra audible noise.
				var char_pos = i - index_offset
				char_delays[char_pos] = (
					char_delays[char_pos] if char_delays.has(char_pos) else 0) + TIMER_DELAY
				index_offset += 1

func is_page_complete():
	return label.visible_characters == len(label.text)

# Increments the visible character count and return the index of the
# most recently printed character.
func increment_visible_characters():
	if label.visible_characters < len(label.text):
		label.visible_characters = label.visible_characters + 1
	return label.visible_characters - 1

func print_character():
	var text_pos = increment_visible_characters()
	# Special case: don't play the sound for periods '.'.
	if label.text[text_pos] != '.':
		sample_player.play()

	# Clear wait time in case we were delayed from the last char.
	timer.wait_time = TIMER_NORMAL

	# Update timer wait time if delayed.
	var char_pos = label.visible_characters
	if char_delays.has(char_pos):
		timer.wait_time = TIMER_NORMAL + char_delays[char_pos]

func on_timeout():
	print_character()
	if not is_page_complete():
		timer.start()