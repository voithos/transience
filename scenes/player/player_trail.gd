extends Line2D

# Player after-trail. This scene should be added to the level's node at the beginning of
# the player node's lifecycle. It queries the player for its position and follows along.
#
# Note that this node should *not* live as a child of anything other than the level itself;
# it relies on its own position being the global origin (0, 0), since it adds points based
# on global position.

onready var player_controller = get_node("/root/player_controller")

const MAX_TRAIL_LENGTH = 128
const NEW_POINT_DISTANCE = 2
# Lifetime of a single trail point.
const TRAIL_POINT_LIFETIME = .05

# Offset so that the trail appears at the player's feet.
const Y_OFFSET = 25

var _last_pos = null
var _accumulated_distance = NEW_POINT_DISTANCE + 1  # We want to unconditionally draw the first point.
var _elapsed_time = 0

func _process(delta):
	if not player_controller.player.is_in_throwback():
		_attempt_add_point()
	else:
		_attempt_remove_point()

	_remove_points_if_above_max()
	_decay_points(delta)

func _attempt_add_point():
	var player_pos = player_controller.player.global_position
	_update_accumulated_distance(player_pos)

	# Only add new points if the distance is large enough.
	if _accumulated_distance > NEW_POINT_DISTANCE:
		add_point(player_pos + Vector2(0, Y_OFFSET))
		_accumulated_distance -= NEW_POINT_DISTANCE

func _attempt_remove_point():
	var player_pos = player_controller.player.global_position
	_update_accumulated_distance(player_pos, true) # negate

	# Only remove new points if the distance has passed the threshold.
	if _accumulated_distance <= 0:
		if get_point_count() > 0:
			remove_point(get_point_count() - 1)
		_accumulated_distance += NEW_POINT_DISTANCE

func _update_accumulated_distance(player_pos, negate=false):
	if _last_pos:
		var distance_change = player_pos.distance_to(_last_pos)
		# When throwing back, we pull the distance in reverse.
		_accumulated_distance += distance_change * (-1 if negate else 1)
	_last_pos = player_pos

func _remove_points_if_above_max():
	while get_point_count() > MAX_TRAIL_LENGTH:
		remove_point(0)

func _decay_points(delta):
	_elapsed_time += delta
	while _elapsed_time > TRAIL_POINT_LIFETIME:
		if get_point_count() > 0:
			remove_point(0)
		_elapsed_time -= TRAIL_POINT_LIFETIME