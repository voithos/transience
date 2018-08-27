extends Node

# Common steering manager for entity nodes. Used to queue up steering operations and
# steer all at once.

onready var steering = get_node("/root/steering")

# Common state.
var entity
var current_steering = Vector2(0, 0)
var wander_angle

func _init(entity, wander_angle=0):
	self.entity = entity
	self.wander_angle = wander_angle

func reset_wander_angle(wander_angle=0):
	self.wander_angle = wander_angle

func seek(target_entity):
	current_steering += steering.seek(
		entity.global_position, target_entity.global_position,
		entity.current_motion, entity.SPEED)

func flee(target_entity):
	current_steering += steering.flee(
		entity.global_position, target_entity.global_position,
		entity.current_motion, entity.SPEED)

func pursue(target_entity):
	current_steering += steering.pursue(
		entity.global_position, target_entity.global_position,
		entity.current_motion, target_entity.current_motion,
		entity.SPEED, target_entity.SPEED)

func evade(target_entity):
	current_steering += steering.evade(
		entity.global_position, target_entity.global_position,
		entity.current_motion, target_entity.current_motion,
		entity.SPEED, target_entity.SPEED)

func arrive(target_entity):
	current_steering += steering.arrive(
		entity.global_position, target_entity.global_position, entity.ARRIVE_RADIUS,
		entity.current_motion, entity.SPEED)

func wander():
	current_steering += steering.wander(
		entity.global_position, entity.WANDER_DISTANCE, entity.WANDER_RADIUS,
		wander_angle, entity.current_motion)
	wander_angle = steering.next_wander_angle(wander_angle, entity.WANDER_ANGLE_CHANGE)

func steer():
	var motion = steering.steer(current_steering, entity.current_motion, entity.SPEED, entity.STEERING_FORCE, entity.MASS)
	current_steering.x = 0
	current_steering.y = 0
	return motion