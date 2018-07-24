extends Node

# Defines common steering behavior logic for the game. This is intentionally 

# Seeks the target from the given position, naturally altering the heading.
# Returns the new motion vector.
func seek(position, target, max_speed, current_motion, max_force, mass):
	var desired_motion = (target - position).normalized() * max_speed
	var steering = desired_motion - current_motion
	
	# Limit the steering vector to some max length.
	steering = steering.clamped(max_force)
	# Also limit it by the entity's mass.
	steering = steering / mass

	return (current_motion + steering).clamped(max_speed)