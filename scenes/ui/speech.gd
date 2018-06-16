extends Sprite

onready var timer = get_node("Timer")
const TIMER_NORMAL = 0.05
const TIMER_DELAYED = 1.0

onready var label = get_node("RichTextLabel")

# The speech data as an array of strings.
var speech_data = ["[center]It's dangerous to go alone...\nYou have no chance to survive\nmake your time[/center]", "Welcome to a thing"]
var page = 0

func _ready():
	begin_if_ready()

func init(speech_data):
	self.speech_data = speech_data
	begin_if_ready()

func begin_if_ready():
	if speech_data:
		timer.wait_time = TIMER_NORMAL
		timer.connect("timeout", self, "on_timeout")
		timer.start()
		
		label.bbcode_text = speech_data[page]
		label.visible_characters = 0

func on_timeout():
	# TODO: Add delay support.
	if label.visible_characters < len(speech_data[page]):
		label.visible_characters = label.visible_characters + 1