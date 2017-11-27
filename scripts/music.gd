extends Node

var level1_theme = preload("res://assets/music/level1.ogg")
var battle_theme = preload("res://assets/music/battle.ogg")

var level1_player
var battle_player

# The last StreamPlayer that was active.
var last_player = null

func _ready():
	level1_player = create_player(level1_theme)
	battle_player = create_player(battle_theme)

func create_player(stream):
	var player = StreamPlayer.new()
	add_child(player)
	player.set_stream(stream)
	player.set_loop(true)
	return player

func play_level1():
	level1_player.play()
	last_player = level1_player

func battle_start():
	last_player.stop()
	battle_player.play()

func battle_end():
	battle_player.stop()
	last_player.play()