extends CharacterBody3D


## Moving body properties
# Pace in meters per second
@export var speed: float = 14.0

# Downward acceleration whien in the air in meters per second squared
@export var fall_acceleration: float = 75.0

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	# Local variable to hold input direction
	var direction = Vector3.ZERO
	
	# Check for each move input and update direction (X and Z axes)
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1


	if direction != Vector3.ZERO:
		direction = direction.normalized()
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
