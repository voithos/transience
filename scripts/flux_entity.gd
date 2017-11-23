extends "res://scripts/entity.gd"

signal flux_changed

export (int) var MAX_FLUX = 100
onready var flux = 0

const FLUX_PER_DELTA_TIME = 10 # Arbitrary, for now
const FLUX_GAIN_RATE = .2 # Arbitrary, for now

func move_entity(motion, dir):
	heal_flux(motion.length() * FLUX_GAIN_RATE)
	.move_entity(motion, dir)
	
func heal_flux(amount):
	var previous_flux = flux
	flux = min(flux + amount, MAX_FLUX)

	if flux != previous_flux:
		emit_signal("flux_changed", flux)

func can_throwback(delta):
	return (delta * FLUX_PER_DELTA_TIME) <= flux
	
func throwback(delta):
	assert(can_throwback(delta))
	flux -= delta * FLUX_PER_DELTA_TIME
	emit_signal("flux_changed", flux)
	# TODO: Actually perform the throwback.