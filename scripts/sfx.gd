extends Node

# Centralized SFX management.
# This node handles audio effects, and is aware of the audio_alt system
# used to apply effects.

const MIN_DB = -80.0
const DEFAULT_DB = 0.0
const SFX_DB = -20.0

const SAMPLES = {
	"slice": preload("res://assets/sfx/slice.wav"),
	"throwback": preload("res://assets/sfx/throwback.wav"),
	"damaged": preload("res://assets/sfx/damaged.wav"),
}

# To allow multiple samples to be played simultaneously,
# we create a pool of stream players that we use successively.
const PLAYER_POOL_SIZE = 8
var player_pool = []
var alt_player_pool = []
# Index of the current player in the pool.
var next_player = 0

func _ready():
	_init_stream_players()

func _init_stream_players():
	for i in range(PLAYER_POOL_SIZE):
		var player = AudioStreamPlayer.new()
		var alt_player = AudioStreamPlayer.new()
		add_child(player)
		add_child(alt_player)
		player.bus = "SFX"
		alt_player.bus = "SFXAlt"
		player_pool.append(player)
		alt_player_pool.append(alt_player)

func _get_next_player_idx():
	var next = next_player
	next_player = (next_player + 1) % PLAYER_POOL_SIZE
	return next

func play(sample):
	assert(sample in SAMPLES)
	var stream = SAMPLES[sample]
	var idx = _get_next_player_idx()

	var player = player_pool[idx]
	var alt_player = alt_player_pool[idx]

	player.stream = stream
	alt_player.stream = stream
	player.volume_db = SFX_DB
	alt_player.volume_db = SFX_DB
	player.play()
	alt_player.play()