extends YSort

# Base controller for levels.
var char
var music

const STATE_IDLE = "IDLE"
const STATE_BATTLE = "BATTLE"

var current_state = STATE_IDLE
var previous_state = STATE_IDLE

const BATTLE_END_LAG = 2  # In seconds
var battle_delta = 0

func _ready():
	var nodes = get_tree().get_nodes_in_group("char")
	assert(nodes.size() == 1)
	char = nodes[0]
	music = get_node("/root/music")

	set_fixed_process(true)

func change_state(new_state):
	if new_state == current_state:
		return
	previous_state = current_state
	current_state = new_state

func _fixed_process(delta):
	check_battle_triggers(delta)

func check_battle_triggers(delta):
	var is_in_battle = false
	var enemies = get_tree().get_nodes_in_group("enemies")
	var charpos = char.get_global_pos()

	var enemy_in_range = false
	for enemy in enemies:
		var d = charpos.distance_squared_to(enemy.get_global_pos())
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
	if current_state == STATE_IDLE:
		return
	change_state(STATE_IDLE)
	music.battle_end()