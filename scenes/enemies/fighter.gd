extends "res://scripts/enemy.gd"

func _ready():
	set_process(true)
	set_fixed_process(true)

func _process(delta):
	enemy_process(delta)

func _fixed_process(delta):
	# Attack slide motion.
	if current_state == STATE_ATTACK:
		slide_in_dir(get_dir(), delta)

func on_attack_triggered():
	detect_directional_area_attack_collisions("char")
	sample_player.play("slice")
	.on_attack_triggered()

func get_attack_range():
	return 25

func get_attack_range_buffer():
	return 5

func get_attack_probability():
	return 0.6

func get_attack_cooldown():
	return 0.25 + (randf() / 2)