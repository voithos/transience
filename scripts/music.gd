extends Node

# Music management. Battle track vs background tracks are logically separate;
# battle tracks are restarted every time they play, background tracks are merely paused.

const FADE_TIME = 2.5
const MIN_DB = -80.0
const DEFAULT_DB = 0.0

const MUSIC_DB = -20.0

class MusicBox extends Node:
	var player
	# We have two players to allow simultaneous playback into effects-based
	# audio buses.
	var alt_player
	var tween
	var last_playback_pos = 0
	
	func _init(stream):
		player = AudioStreamPlayer.new()
		alt_player = AudioStreamPlayer.new()
		add_child(player)
		add_child(alt_player)
		player.bus = "Music"
		alt_player.bus = "MusicAlt"
		player.stream = stream
		alt_player.stream = stream
		player.volume_db = MIN_DB
		alt_player.volume_db = MIN_DB
		
		tween = Tween.new()
		add_child(tween)
		self.tween.connect("tween_completed", self, "on_fade_complete")

	func set_volume_db(volume_db):
		player.volume_db = volume_db
		alt_player.volume_db = volume_db

	func fade_in():
		player.play(last_playback_pos)
		alt_player.play(last_playback_pos)
		last_playback_pos = 0
		tween.remove_all()
		tween.interpolate_method(self, "set_volume_db", player.volume_db, MUSIC_DB, \
				FADE_TIME, Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()

	func fade_out():
		tween.remove_all()
		tween.interpolate_method(self, "set_volume_db", player.volume_db, MIN_DB, \
				FADE_TIME, Tween.TRANS_EXPO, Tween.EASE_IN)
		tween.start()

	func is_active():
		return tween.is_active()

	func play():
		player.volume_db = MUSIC_DB
		alt_player.volume_db = MUSIC_DB
		player.play()
		alt_player.play()

	func on_fade_complete(object, key):
		if player.volume_db == MIN_DB:
			tween.remove_all()
			last_playback_pos = player.get_playback_position()
			player.stop()
			alt_player.stop()

var level1_theme = preload("res://assets/music/level1.ogg")
var battle_theme = preload("res://assets/music/battle.ogg")

var level1_musicbox
var battle_musicbox

# The last MusicBox that was active.
var last_musicbox = null

func _ready():
	_load_music()

func _load_music():
	level1_musicbox = MusicBox.new(level1_theme)
	add_child(level1_musicbox)

	battle_musicbox = MusicBox.new(battle_theme)
	add_child(battle_musicbox)

func play_level1():
	level1_musicbox.play()
	last_musicbox = level1_musicbox

func battle_start():
	last_musicbox.fade_out()

	# Battle music restarts each time (unless the fade-out isn't done).
	if not battle_musicbox.is_active():
		battle_musicbox.last_playback_pos = 0
	battle_musicbox.fade_in()

func battle_end():
	battle_musicbox.fade_out()
	last_musicbox.fade_in()
