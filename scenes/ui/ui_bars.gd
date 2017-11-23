
extends CanvasLayer

onready var health_bar = get_node("HealthBar")
onready var flux_bar = get_node("FluxBar")

func _ready():
	setup_listeners()

func setup_listeners():
	var nodes = get_tree().get_nodes_in_group("char")
	assert(nodes.size() == 1)
	var char = nodes[0]
	char.connect("health_changed", self, "on_health_changed")
	char.connect("flux_changed", self, "on_flux_changed")
	
	# Initial reset.
	health_bar.set_value(char.health_ratio() * 100)
	flux_bar.set_value(char.flux_ratio() * 100)

func on_health_changed(ratio):
	health_bar.set_value(ratio * 100)

func on_flux_changed(ratio):
	flux_bar.set_value(ratio * 100)