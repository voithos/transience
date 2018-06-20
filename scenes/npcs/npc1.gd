extends "res://scripts/npc.gd"

const SPEECH_DATA = ["""
UNHANDED PHILOSOPHY!###
Someone spilled KETCHUP# on my PANTS
""",
]

func _ready():
	self.speech_data = SPEECH_DATA