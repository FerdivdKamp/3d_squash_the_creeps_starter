extends CharacterBody3D

const MovementMath = preload("res://movement_math.gd")


## Moving body properties
# Pace in meters per second
@export var speed: float = 14.0

# Downward acceleration whien in the air in meters per second squared
@export var fall_acceleration: float = 75.0

@export var jump_impulse: int = 20

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
