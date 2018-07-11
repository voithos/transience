extends CanvasLayer

# UI bars for the in-game UI. Monitors health and flux.

const BAR_TWEEN_TIME = 0.2

onready var health_bar = get_node("HealthBar")
onready var flux_bar = get_node("FluxBar")
onready var health_tween = get_node("HealthBarTween")
onready var flux_tween = get_node("FluxBarTween")

onready var player_controller = get_node("/root/player_controller")

func _ready():
	call_deferred("setup_listeners")

func setup_listeners():
	player_controller.player.connect("health_changed", self, "on_health_changed")
	player_controller.player.connect("flux_changed", self, "on_flux_changed")
	
	# Initial reset.
	health_bar.set_value(player_controller.player.health_ratio() * 100)
	flux_bar.set_value(player_controller.player.flux_ratio() * 100)

func on_health_changed(ratio):
	health_tween.interpolate_property(health_bar, "value", health_bar.get_value(), ratio * 100, \
			BAR_TWEEN_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	health_tween.start()

func on_flux_changed(ratio):
	flux_tween.interpolate_property(flux_bar, "value", flux_bar.get_value(), ratio * 100, \
			BAR_TWEEN_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	flux_tween.start()