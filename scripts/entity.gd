extends KinematicBody2D

# Common health management.

signal health_changed
signal died

var health
export var max_health = 10

func _ready():
	health = max_health

func take_damage(damage):
	# TODO: Add state management so that take_damage/heal are no-ops
	# when entity is dead.
	health -= damage
	if health <= 0:
		health = 0
		emit_signal("died")
	else:
		emit_signal("health_changed", health)

func heal(amount):
	health = min(health + amount, max_health)

func health_ratio():
	return health / max_health
