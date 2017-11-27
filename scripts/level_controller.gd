extends YSort

# Base controller for levels.
var char
var music

const ENEMY_TRIGGER_DISTANCE = 100
const ENEMY_TRIGGER_DISTANCE_SQUARED = ENEMY_TRIGGER_DISTANCE * ENEMY_TRIGGER_DISTANCE

const STATE_IDLE = "IDLE"
const STATE_BATTLE = "BATTLE"

var current_state = STATE_IDLE
var previous_state = STATE_IDLE

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
	check_battle_triggers()

func check_battle_triggers():
	var is_in_battle = false
	var enemies = get_tree().get_nodes_in_group("enemies")
	var charpos = char.get_global_pos()

	for enemy in enemies:
		var d = charpos.distance_squared_to(enemy.get_global_pos())
		if d < ENEMY_TRIGGER_DISTANCE_SQUARED:
			start_battle()
			return

	# If we reach here, then we aren't in a battle.
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