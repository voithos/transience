extends YSort

# Base controller for levels.
onready var music = get_node("/root/music")
onready var player_controller = get_node("/root/player_controller")

# Common scenes to add to each level.
const world_environment_scene = preload("res://scenes/levels/world_environment.tscn")
const ui_bars_scene = preload("res://scenes/ui/ui_bars.tscn")
const light_particles_scene = preload("res://scenes/effects/light_particles.tscn")

# Level state.
const STATE_EXPLORING = "EXPLORING"
const STATE_BATTLE = "BATTLE"

var current_state = STATE_EXPLORING
var previous_state = STATE_EXPLORING

const BATTLE_END_LAG = 2  # In seconds
var battle_delta = 0

func _ready():
	add_to_group("level")
	
	add_common_nodes()

# Adds nodes that are common to all "levels".
func add_common_nodes():
	var world_environment = world_environment_scene.instance()
	add_child(world_environment)
	move_child(world_environment, 0)
	
	add_child(light_particles_scene.instance())
	add_child(ui_bars_scene.instance())

func change_state(new_state):
	if new_state == current_state:
		return
	previous_state = current_state
	current_state = new_state

func _physics_process(delta):
	check_battle_triggers(delta)

func check_battle_triggers(delta):
	# TODO: Should this logic be in enemy.gd instead?
	var is_in_battle = false
	var enemies = get_tree().get_nodes_in_group("enemies")
	var playerpos = player_controller.get_player_pos()

	var enemy_in_range = false
	for enemy in enemies:
		var d = playerpos.distance_squared_to(enemy.global_position)
		if d < enemy.TRIGGER_DISTANCE_SQUARED:
			enemy_in_range = true
			start_battle()
			enemy.start_battle()

	if enemy_in_range:
		battle_delta = 0
	else:
		battle_delta += delta
		if battle_delta > BATTLE_END_LAG:
			stop_battle()

func start_battle():
	if current_state == STATE_BATTLE:
		return
	change_state(STATE_BATTLE)
	music.battle_start()

func stop_battle():
	if current_state == STATE_EXPLORING:
		return
	change_state(STATE_EXPLORING)
	music.battle_end()