extends Sprite

const speech_scene = preload("res://scenes/ui/speech.tscn")

# Common code for NPCs.
# Specific NPCs should override the `speech_data` field to setup dialogue.

var speech_data = []

onready var cutscene = get_node("/root/cutscene")
var player

# The distance that the player has to be from the npc in order to trigger dialogue.
var DIALOGUE_DISTANCE = 25
var DIALOGUE_DISTANCE_SQUARED = DIALOGUE_DISTANCE * DIALOGUE_DISTANCE

func _ready():
	add_to_group("npcs")

	# Need to defer it because not all _ready() functions have been called (and thus groups haven't been set up yet).
	call_deferred("configure_nodes")

func _input(event):
	# Handle any edge cases where input is queued before the player is initialized.
	# Most apparent while debugging a scene.
	if not player: return

	# Don't trigger a speech dialog if we're already in a cutscene.
	if cutscene.is_in_cutscene: return

	# Don't trigger the dialog again if it just completed due to this input event.
	if event.has_meta("consumed_by") and event.get_meta("consumed_by") == "speech":
		return

	if self.global_position.distance_squared_to(player.global_position) < DIALOGUE_DISTANCE_SQUARED:
		if Input.is_action_just_pressed("trans_accept") and is_player_facing_npc():
			start_dialogue()

func start_dialogue():
	# TODO: Do not allow motion (nor new speech dialogs) from getting created while
	# in a dialogue. Also, connect to the speech complete signal.
	var speech = speech_scene.instance()
	add_child(speech)
	cutscene.start_cutscene()
	speech.connect("speech_completed", self, "end_dialogue")
	speech.init(speech_data)

func end_dialogue():
	cutscene.end_cutscene()

func is_player_facing_npc():
	var dir = player.get_dir()
	# Check the directions.
	if dir == "left" and self.global_position.x < player.global_position.x:
		return true
	elif dir == "right" and self.global_position.x > player.global_position.x:
		return true
	elif dir == "up" and self.global_position.y < player.global_position.y:
		return true
	elif dir == "down" and self.global_position.y > player.global_position.y:
		return true

	return false

func configure_nodes():
	# Get a ref to the player so we can chase it.
	var tree = get_tree()
	var nodes = tree.get_nodes_in_group("player")
	assert(nodes.size() == 1)
	player = nodes[0]