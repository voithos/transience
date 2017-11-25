extends CanvasLayer

const BAR_TWEEN_TIME = 0.2

onready var health_bar = get_node("HealthBar")
onready var flux_bar = get_node("FluxBar")
onready var health_tween = get_node("HealthBarTween")
onready var flux_tween = get_node("FluxBarTween")

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
	health_tween.interpolate_property(health_bar, "range/value", health_bar.get_value(), ratio * 100, \
			BAR_TWEEN_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	health_tween.start()

func on_flux_changed(ratio):
	flux_tween.interpolate_property(flux_bar, "range/value", flux_bar.get_value(), ratio * 100, \
			BAR_TWEEN_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	flux_tween.start()