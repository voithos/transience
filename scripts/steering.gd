extends Node

# Defines common steering behavior logic for the game. This is intentionally 
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

# Arrives at the target's position, slowing down after passing slow_radius.
# Based on: https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-flee-and-arrival--gamedev-1303
# Returns the desired steering vector.
func arrival(position, target, slow_radius, current_motion, max_speed):
	var desired_motion = target - position
	var distance = desired_motion.length()

	desired_motion = desired_motion.normalized() * max_speed
	if distance < slow_radius:
		desired_motion *= (distance / slow_radius)
	return desired_motion - current_motion

# Wanders based on a "displacement circle" and a changing wander angle.
# Based on: https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-wander--gamedev-1624
# Returns a pair of the desired steering vector and the new wander angle.
func wander(position, circle_distance, circle_radius, wander_angle, angle_change, current_motion):
	var circle_center = current_motion.normalized() * circle_distance
	# Initial direction doesn't matter, as we will rotate it.
	var displacement = Vector2(0, -1) * circle_radius
	
	# Set the displacement angle.
	var disp_length = displacement.length()
	displacement.x = cos(wander_angle) * disp_length
	displacement.y = sin(wander_angle) * disp_length

	wander_angle += randf() * angle_change - angle_change * 0.5
	var steering = circle_center + displacement
	return [steering, wander_angle]

# Applies a steering to the current_motion, taking into account force and mass.
# Returns the new motion vector.
func steer(steering, current_motion, max_speed, max_force, mass):
	# Limit the steering vector to some max length.
	steering = steering.clamped(max_force)
	# Also limit it by the entity's mass.
	steering = steering / mass

	return (current_motion + steering).clamped(max_speed)