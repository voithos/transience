extends Sprite

const speech_scene = preload("res://scenes/ui/speech.tscn")

# Common code for NPCs.
# Specific NPCs should override the `speech_data` field to setup dialogue.

var speech_data = []

# The distance that the player has to be from the npc in order to trigger dialogue.
var DIALOGUE_DISTANCE = 25
var DIALOGUE_DISTANCE_SQUARED = DIALOGUE_DISTANCE * DIALOGUE_DISTANCE

var player

func _ready():
	add_to_group("npcs")

	# Need to defer it because not all _ready() functions have been called (and thus groups haven't been set up yet).
	call_deferred("configure_nodes")

func _input(event):
	# TODO: This particular line seems to blow up if there are mouse events present before
	# the node is ready...? Godot bug?
	if self.global_position.distance_squared_to(player.global_position) < DIALOGUE_DISTANCE_SQUARED:
		if event.is_action_pressed("trans_accept") and is_player_facing_npc():
			begin_dialogue()

func begin_dialogue():
	# TODO: Do not allow motion (nor new speech dialogs) from getting created while
	# in a dialogue. Also, connect to the speech complete signal.
	var speech = speech_scene.instance()
	add_child(speech)
	speech.init(speech_data)

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