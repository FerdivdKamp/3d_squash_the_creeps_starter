extends CharacterBody3D

# Minimal speed
@export var minimal_speed: int = 10

# Maximum speed
@export var maximum_speed: int = 18

func _physics_process(_delta):
	move_and_slide()


# This will be called from the main scene
func initialize(start_position, player_position):
	# We position the mob by placing it at the start_position
	# Face player
	look_at_from_position(start_position, player_position, Vector3.UP)

	# Rotate the mob randomnly
	rotate_y(randf_range(-PI / 4, PI / 4))

	# Calculate a random speed for the mob
	var random_speed = randi_range(minimal_speed, maximum_speed)

	# Calculate forwward velocity based on the random speed
	velocity = Vector3.FORWARD * random_speed
	
	# Rotate the velocity vector based on the mob's current rotation
	velocity = velocity.rotated(Vector3.UP, rotation.y)

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	pass # Replace with function body.


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
