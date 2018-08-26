extends Node

# Defines common steering behavior logic for the game. This is intentionally 


# Seeks the target from the given position, naturally altering the heading.
# Returns the new motion vector.
func seek(position, target, max_speed, current_motion, max_force, mass):
	var desired_motion = (target - position).normalized() * max_speed
	var steering = desired_motion - current_motion
	return _steer(steering, max_speed, current_motion, max_force, mass)

# Flees from the target, naturally altering the heading.
# Returns the new motion vector.
func flee(position, target, max_speed, current_motion, max_force, mass):
	var desired_motion = (position - target).normalized() * max_speed
	var steering = desired_motion - current_motion
	return _steer(steering, max_speed, current_motion, max_force, mass)

# Arrives at the target's position, slowing down after passing slow_radius.
# Returns the new motion vector.
func arrival(position, target, slow_radius, max_speed, current_motion, max_force, mass):
	var desired_motion = target - position
	var distance = desired_motion.length()

	desired_motion = desired_motion.normalized() * max_speed
	if distance < slow_radius:
		desired_motion *= (distance / slow_radius)
	var steering = desired_motion - current_motion
	return _steer(steering, max_speed, current_motion, max_force, mass)

# Applies a steering to the current_motion, taking into account force and mass.
# Used by steering functions.
func _steer(steering, max_speed, current_motion, max_force, mass):
	# Limit the steering vector to some max length.
	steering = steering.clamped(max_force)
	# Also limit it by the entity's mass.
	steering = steering / mass

	return (current_motion + steering).clamped(max_speed)