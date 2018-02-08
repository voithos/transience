extends Node

# Music management. Battle track vs background tracks are logically separate;
# battle tracks are restarted every time they play, background tracks are merely paused.

const FADE_TIME = 2.5
const MIN_DB = -80.0
const MAX_DB = -20.0

# TODO: Clean this up into a class.
var level1_theme = preload("res://assets/music/level1.ogg")
var level1_player
var level1_tween

var battle_theme = preload("res://assets/music/battle.ogg")
var battle_player
var battle_tween

# The last AudioStreamPlayer that was active.
var last_stream_player = null
var last_tween = null
var last_playback_pos = 0

func _ready():
	level1_player = create_player(level1_theme)
	level1_tween = Tween.new()
	add_child(level1_tween)
	level1_tween.connect("tween_completed", self, "on_fade_complete", [level1_tween])

	battle_player = create_player(battle_theme)
	battle_tween = Tween.new()
	add_child(battle_tween)
	battle_tween.connect("tween_completed", self, "on_fade_complete", [battle_tween])
	battle_player.volume_db = MIN_DB

func create_player(stream):
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.set_stream(stream)
	return player

func on_fade_complete(object, key, tween):
	print('mwahahah fade complete')
	if object.volume_db == MIN_DB:
		tween.remove_all()
		last_playback_pos = object.get_playback_position()
		object.stop()

func fade_in(player, tween):
	player.play(last_playback_pos)
	last_playback_pos = 0
	tween.remove_all()
	tween.interpolate_property(player, "volume_db", player.volume_db, MAX_DB, \
			FADE_TIME, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()

func fade_out(player, tween):
	tween.remove_all()
	tween.interpolate_property(player, "volume_db", player.volume_db, MIN_DB, \
			FADE_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
	tween.start()

func play_level1():
	level1_player.volume_db = MAX_DB
	level1_player.play()
	last_stream_player = level1_player
	last_tween = level1_tween

func battle_start():
	fade_out(last_stream_player, last_tween)

	# Battle music restarts each time (unless the fade-out isn't done).
	if not battle_tween.is_active():
		battle_player.play(0)
	fade_in(battle_player, battle_tween)

func battle_end():
	fade_out(battle_player, battle_tween)
	fade_in(last_stream_player, last_tween)
