extends CharacterBody3D

const MovementMath = preload("res://movement_math.gd")


## Moving body properties
# Pace in meters per second
@export var speed: float = 14.0

# Downward acceleration whien in the air in meters per second squared
@export var fall_acceleration: float = 75.0

@export var jump_impulse: int = 20

@export var bounce_impulse: int = 16


var target_velocity = Vector3.ZERO

func _physics_process(delta):
	# Local variable to hold input direction
	var direction := MovementMath.direction(
		Input.is_action_pressed("move_left"),
		Input.is_action_pressed("move_right"),
		Input.is_action_pressed("move_forward"),
		Input.is_action_pressed("move_back")
	)


	if direction != Vector3.ZERO:
		# Setting the basis property for rotation
		$Pivot.basis = Basis.looking_at(direction)

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	# Vertical Velocity
	if not is_on_floor(): # If in the air fall towards the floor (gravity)
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse

	# Iterate through all collisions that occurred this frame
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)

		# If there are duplicate collisions with a mob in a single frame
		# the mob will be deleted after the first collision, and a second call to
		# get_collider will return null, leading to a null pointer when calling
		# collision.get_collider().is_in_group("mob").
		# This block of code prevents processing duplicate collisions.
		if collision.get_collider() == null:
			continue

		# If the collider is with a mob
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			# we check that we are hitting it from above.
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# If so, we squash it and bounce.
				mob.squash()
				target_velocity.y = bounce_impulse
				# Prevent further duplicate calls.
				break
