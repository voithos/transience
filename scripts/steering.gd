extends Node

# Defines common steering behavior logic for the game. This is intentionally 


# Seeks the target from the given position, naturally altering the heading.
# Returns the new motion vector.
func seek(position, target, max_speed, current_motion, max_force, mass):
	var desired_motion = (target - position).normalized() * max_speed
	return _steer(desired_motion, max_speed, current_motion, max_force, mass)

# Flees from the target, naturally altering the heading.
# Returns the new motion vector.
func flee(position, target, max_speed, current_motion, max_force, mass):
	var desired_motion = (position - target).normalized() * max_speed
	return _steer(desired_motion, max_speed, current_motion, max_force, mass)

# Steers the current_motion toward the desired_motion, taking into account force and mass.
# Used by seek() and flee().
func _steer(desired_motion, max_speed, current_motion, max_force, mass):
	var steering = desired_motion - current_motion
	
	# Limit the steering vector to some max length.
	steering = steering.clamped(max_force)
	# Also limit it by the entity's mass.
	steering = steering / mass

	return (current_motion + steering).clamped(max_speed)
