extends Sprite

const speech_scene = preload("res://scenes/ui/speech.tscn")

# Common code for NPCs.
# Specific NPCs should override the `speech_data` field to setup dialogue.

# `speech_data` should be a list of lists, each sublist representing a single
# conversation.
var speech_data = []
# Each NPC may have a series of separate conversations that increment as
# the player talks to them, until there are no more left. At that point,
# the last conversation is repeated.
var conversation = 0

onready var cutscene = get_node("/root/cutscene")
onready var player_controller = get_node("/root/player_controller")

# The distance that the player has to be from the npc in order to trigger dialogue.
var DIALOGUE_DISTANCE = 25
var DIALOGUE_DISTANCE_SQUARED = DIALOGUE_DISTANCE * DIALOGUE_DISTANCE

func _ready():
	add_to_group("npcs")

func _input(event):
	# Don't trigger a speech dialog if we're already in a cutscene.
	if cutscene.is_in_cutscene: return

	# Don't trigger the dialog again if it just completed due to this input event.
	if event.has_meta("consumed_by") and event.get_meta("consumed_by") == "speech":
		return

	if self.global_position.distance_squared_to(player_controller.get_player_pos()) < DIALOGUE_DISTANCE_SQUARED:
		if Input.is_action_just_pressed("trans_accept") and is_player_facing_npc():
			start_dialogue()

func start_dialogue():
	assert(len(speech_data) >= 1)

	var speech = speech_scene.instance()
	add_child(speech)
	cutscene.start_cutscene()
	speech.connect("speech_completed", self, "end_dialogue")
	speech.init(speech_data[conversation])

func end_dialogue():
	cutscene.end_cutscene()
	if conversation < len(speech_data) - 1:
		conversation += 1

func is_player_facing_npc():
	var playerpos = player_controller.get_player_pos()
	var dir = player_controller.get_player_dir()
	# Check the directions.
	if dir == "left" and self.global_position.x < playerpos.x:
		return true
	elif dir == "right" and self.global_position.x > playerpos.x:
		return true
	elif dir == "up" and self.global_position.y < playerpos.y:
		return true
	elif dir == "down" and self.global_position.y > playerpos.y:
		return true

	return false