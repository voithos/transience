extends "res://scripts/enemy.gd"

func _physics_process(delta):
	enemy_physics_process(delta)

	# Attack slide motion.
	if current_state == STATE_ATTACK:
		slide_in_dir(get_dir())

func on_attack_triggered():
	var total_damage = detect_directional_area_attack_collisions("player")
	if total_damage == 0:
		play_sample("slice")
	.on_attack_triggered()

func on_damaged(damage, attacked_direction):
	# Fighters are tough. :)
	# If they get hit while in stagger, they won't re-stagger.
	if current_state != STATE_STAGGER:
		.on_damaged(damage, attacked_direction)

func get_attack_range():
	return 25

func get_attack_range_buffer():
	return 5

func get_attack_probability():
	return 0.6

func get_attack_cooldown():
	return 0.25 + (randf() / 2)