extends Node

# Music management. Battle track vs background tracks are logically separate;
# battle tracks are restarted every time they play, background tracks are merely paused.

const FADE_TIME = 2.5
const MIN_DB = -80.0
const MAX_DB = 0.0

# TODO: Clean this up into a class.
var level1_theme = preload("res://assets/music/level1.ogg")
var level1_player
var level1_tween

var battle_theme = preload("res://assets/music/battle.ogg")
var battle_player
var battle_tween

# The last StreamPlayer that was active.
var last_player = null
var last_tween = null

func _ready():
	level1_player = create_player(level1_theme)
	level1_tween = Tween.new()
	add_child(level1_tween)
	level1_tween.connect("tween_complete", self, "on_fade_complete")

	battle_player = create_player(battle_theme)
	battle_tween = Tween.new()
	add_child(battle_tween)
	battle_tween.connect("tween_complete", self, "on_fade_complete")
	battle_player.set_volume_db(MIN_DB)

func create_player(stream):
	var player = StreamPlayer.new()
	add_child(player)
	player.set_stream(stream)
	player.set_loop(true)
	return player

func on_fade_complete(object, key):
	if object.get_volume() == MIN_DB:
		object.set_paused(true)

func fade_in(player, tween):
	player.set_volume(0)
	player.set_paused(false)
	tween.interpolate_property(player, "stream/volume_db", player.get_volume_db(), MAX_DB, \
			FADE_TIME, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()

func fade_out(player, tween):
	tween.interpolate_property(player, "stream/volume_db", player.get_volume_db(), MIN_DB, \
			FADE_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
	tween.start()

func play_level1():
	level1_player.play()
	last_player = level1_player
	last_tween = level1_tween

func battle_start():
	fade_out(last_player, last_tween)

	# Battle music restarts each time.
	battle_player.play(0)
	fade_in(battle_player, battle_tween)

func battle_end():
	fade_out(battle_player, battle_tween)
	fade_in(last_player, last_tween)
