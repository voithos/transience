extends "res://scripts/npc.gd"

const SPEECH_DATA = [[
"""
UNHANDED PHILOSOPHY!###
AH!## Someone spilled KETCHUP# on my PANTS
""","""
Now I'm going to use 6pokemon6
to destroy all 6thing6
"""
], [
"""
MWAHAHAHAHAH
"""
]]

func _ready():
	self.speech_data = SPEECH_DATA