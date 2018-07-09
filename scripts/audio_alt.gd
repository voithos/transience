extends Node

# Audio effects management. This node controls the effect audio buses.
# When other nodes create play music or SFX, by convention, they play the audio
# into both a "normal" bus and an "alt" bus, the latter of which is normally muted.
# This node controls the volume mix between the two bus types.

const MIN_DB = -80.0
const DEFAULT_DB = 0.0

func _ready():
	_setup_audio_buses()

func _setup_audio_buses():
	# The "MasterAlt" bus is always unmuted and at full DB, for simplicity.
	_set_bus_volume_db("MasterAlt", DEFAULT_DB)
	_set_bus_mute("MasterAlt", false)

	for bus in ["MusicAlt", "SFXAlt"]:
		_set_bus_volume_db(bus, MIN_DB)
		_set_bus_mute(bus, true)

func _set_bus_volume_db(bus, volume_db):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), volume_db)

func _set_bus_mute(bus, is_muted):
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), is_muted)