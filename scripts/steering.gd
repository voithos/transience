extends Node

# Defines common steering behavior logic. This is intentionally made to be as generic as possible.
# TODO: Document these functions better.


func _ready():
	randomize() # Re-seed.

# Seeks the target from the given position, naturally altering the heading.
# Based on: https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-seek--gamedev-849
# Returns the desired steering vector.
func seek(position, target, current_motion, max_speed):
	var desired_motion = (target - position).normalized() * max_speed
	return desired_motion - current_motion

# Flees from the target, naturally altering the heading.
# Based on: https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-flee-and-arrival--gamedev-1303
# Returns the desired steering vector.
func flee(position, target, current_motion, max_speed):
	var desired_motion = (position - target).normalized() * max_speed
	return desired_motion - current_motion

func _predict_target(position, target, target_motion, max_target_speed):
	var distance = target - position
	var prediction_factor = distance.length() / max_target_speed
	return target + target_motion * prediction_factor

# Pursues the target, attempting to predict where target will go based on current motion.
# Based on: https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-pursuit-and-evade--gamedev-2946
# Returns the desired steering vector.
func pursue(position, target, current_motion, target_motion, max_speed, max_target_speed):
	var future_target = _predict_target(position, target, target_motion, max_target_speed)
	return seek(position, future_target, current_motion, max_speed)

# Evades the target, attempting to predict where target will go based on current motion.
# Based on: https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-pursuit-and-evade--gamedev-2946
# Returns the desired steering vector.
func evade(position, target, current_motion, target_motion, max_speed, max_target_speed):
	var future_target = _predict_target(position, target, target_motion, max_target_speed)
	return flee(position, future_target, current_motion, max_speed)

# Arrives at the target's position, slowing down after passing arrive_radius.
# Based on: https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-flee-and-arrival--gamedev-1303
# Returns the desired steering vector.
func arrive(position, target, arrive_radius, current_motion, max_speed):
	var desired_motion = target - position
	var distance = desired_motion.length()

	desired_motion = desired_motion.normalized() * max_speed
	if distance < arrive_radius:
		desired_motion *= (distance / arrive_radius)
	return desired_motion - current_motion

# Wanders based on a "displacement circle" and a changing wander angle.
# Based on: https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-wander--gamedev-1624
# Usage code should alter the wander_angle after calling this for each frame,
# using the next_wander_angle() method.
# Returns the desired steering vector.
func wander(position, circle_distance, circle_radius, wander_angle, current_motion):
	var circle_center = current_motion.normalized() * circle_distance
	# Initial direction doesn't matter, as we will rotate it.
	var displacement = Vector2(0, -1) * circle_radius
	
	# Set the displacement angle.
	var disp_length = displacement.length()
	displacement.x = cos(wander_angle) * disp_length
	displacement.y = sin(wander_angle) * disp_length

	return circle_center + displacement

# Generates a wander_angle for the next frame by slightly tweaking the angle randomly.
# Should be used after calling wander().
func next_wander_angle(wander_angle, angle_change):
	wander_angle += randf() * angle_change - angle_change * 0.5
	return wander_angle

# Applies a steering to the current_motion, taking into account force and mass.
# Returns the new motion vector.
func steer(steering, current_motion, max_speed, max_force, mass):
	# Limit the steering vector to some max length.
	steering = steering.clamped(max_force)
	# Also limit it by the entity's mass.
	steering = steering / mass

	return (current_motion + steering).clamped(max_speed)