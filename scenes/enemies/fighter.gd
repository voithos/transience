extends "res://scripts/enemy.gd"

func _ready():
	set_process(true)

func _process(delta):
	enemy_process(delta)
