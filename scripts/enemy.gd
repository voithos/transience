extends "res://scripts/entity.gd"

# Base script for all enemy types.

# The distance that the char has to be from the enemy in order to trigger battle.
export (int) var TRIGGER_DISTANCE = 100
var TRIGGER_DISTANCE_SQUARED

const IDLE_CHANCE_TO_LOOK_AROUND = 0.3
const CHASE_LOCATION_EPSILON = 1.5
var CHASE_LOCATION_EPSILON_SQUARED

const AI_STATE_IDLE = "IDLE"
const AI_STATE_BATTLE = "BATTLE"

var current_ai_state = AI_STATE_IDLE

var char
var navigation_node

func _ready():
	# Cache the square since sqrt() operations are slow.
	TRIGGER_DISTANCE_SQUARED = TRIGGER_DISTANCE * TRIGGER_DISTANCE
	CHASE_LOCATION_EPSILON_SQUARED = CHASE_LOCATION_EPSILON * CHASE_LOCATION_EPSILON
	add_to_group("enemies")
	randomize() # Re-seed.

	# Need to defer it because not all _ready() functions have been called (and thus groups haven't been set up yet).
	call_deferred("configure_nodes")

func configure_nodes():
	# Get a ref to the char so we can chase it.
	var tree = get_tree()
	var nodes = tree.get_nodes_in_group("char")
	assert(nodes.size() == 1)
	char = nodes[0]

	# Also get the level's navigation node so that we can navigate.
	nodes = tree.get_nodes_in_group("level")
	assert(nodes.size() == 1)
	navigation_node = nodes[0].get_node("Navigation2D")

func enemy_process(delta):
	if current_ai_state == AI_STATE_IDLE:
		run_idle_ai(delta)
	elif current_ai_state == AI_STATE_BATTLE:
		run_battle_ai(delta)

func run_idle_ai(delta):
	# Randomly look in a different direction with a certain probability, per second.
	if randf() < IDLE_CHANCE_TO_LOOK_AROUND * delta:
		var dir = DIRECTIONS[randi() % 4]
		play_dir_animation(dir, "idle")

func run_battle_ai(delta):
	if not can_accept_input():
		return

	# Check for distance-to-char and attack.
	var attack_range = pow(get_attack_range(), 2)
	var distance_to_char = get_global_pos().distance_squared_to(char.get_global_pos())
	if distance_to_char < attack_range + get_attack_range_buffer():
		if randf() < get_attack_probability():
			attack()
			return
	
	# Check path to char.
	var path = navigation_node.get_simple_path(get_global_pos(), char.get_global_pos(), false)
	# The first point is always the start node.
	if path.size() > 1:
		var vector = path[1] - get_global_pos()
		var direction = vector.normalized()
		if path.size() > 2 or vector.length_squared() > CHASE_LOCATION_EPSILON_SQUARED:
			# Only move if we're not super close - i.e. haven't reached the epsilon yet.
			var motion = direction * SPEED * delta
			var dir = get_dir_from_motion(motion)
			move_entity(motion, dir)

# To be overridden in subscripts.
func get_attack_range():
	assert(false)

# To be overridden in subscripts.
func get_attack_range_buffer():
	assert(false)

# To be overridden in subscripts.
func get_attack_probability():
	assert(false)

# Initiates a battle with an enemy.
func start_battle():
	current_ai_state = AI_STATE_BATTLE