extends Node

# Audio effects management. This node controls the effect audio buses.
# When other nodes create play music or SFX, by convention, they play the audio
# into both a "normal" bus and an "alt" bus, the latter of which is normally muted.
# This node controls the volume mix between the two bus types.

const MIN_DB = -80.0
const DEFAULT_DB = 0.0

const PAIN_FADE_TIME = 2.0

# The buses that are manipulated in-game.
const BUSES = ["Music", "SFX"]
func _bus_to_alt(bus):
	return bus + "Alt"

var tween

func _ready():
	_setup_tween()
	_setup_audio_buses()

func _setup_tween():
	tween = Tween.new()
	add_child(tween)
	self.tween.connect("tween_completed", self, "_on_fade_complete")

func _setup_audio_buses():
	# The "MasterAlt" bus is always unmuted and at full DB, for simplicity.
	_set_bus_volume_db("MasterAlt", DEFAULT_DB)
	_set_bus_mute("MasterAlt", false)

	for bus in BUSES:
		_set_bus_volume_db(_bus_to_alt(bus), MIN_DB)
		_set_bus_mute(_bus_to_alt(bus), true)

func _set_bus_volume_db(bus, volume_db):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), volume_db)

func _set_bus_mute(bus, is_muted):
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), is_muted)

func _add_bus_effect(bus, effect):
	# TODO: This only supports a single effect at a time right now.
	var idx = AudioServer.get_bus_index(bus)
	if AudioServer.get_bus_effect_count(idx) == 0:
		AudioServer.add_bus_effect(idx, effect)

func _remove_all_bus_effects(bus):
	var idx = AudioServer.get_bus_index(bus)
	while AudioServer.get_bus_effect_count(idx) > 0:
		AudioServer.remove_bus_effect(idx, 0)

func _add_effect_to_alt_buses(effect):
	for bus in BUSES:
		_add_bus_effect(_bus_to_alt(bus), effect)

func _remove_all_effects_from_alt_buses():
	for bus in BUSES:
		_remove_all_bus_effects(_bus_to_alt(bus))

func trigger_pain_effect():
	_switch_to_alt_buses()

	var effect = AudioEffectLowPassFilter.new()
	_add_effect_to_alt_buses(effect)

	tween.remove_all()
	tween.interpolate_method(self, "_update_bus_fade", MIN_DB, DEFAULT_DB, \
			PAIN_FADE_TIME, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.interpolate_method(self, "_update_alt_bus_fade", DEFAULT_DB, MIN_DB, \
			PAIN_FADE_TIME, Tween.TRANS_QUART, Tween.EASE_IN)
	tween.start()

# Quiets the normal buses, unmutes the alt buses, and sets their volume to normal.
func _switch_to_alt_buses():
	for bus in BUSES:
		_set_bus_volume_db(bus, MIN_DB)
		_set_bus_mute(_bus_to_alt(bus), false)
		_set_bus_volume_db(_bus_to_alt(bus), DEFAULT_DB)

# Updates the bus fade for the non-alt buses. Meant to be used via tween.
func _update_bus_fade(volume_db):
	for bus in BUSES:
		_set_bus_volume_db(bus, volume_db)

# Updates the bus fade for the alt buses. Meant to be used via tween.
func _update_alt_bus_fade(volume_db):
	for bus in BUSES:
		_set_bus_volume_db(_bus_to_alt(bus), volume_db)

func _on_fade_complete(object, key):
	_remove_all_effects_from_alt_buses()
	for bus in BUSES:
		_set_bus_mute(_bus_to_alt(bus), true)