extends GutTest

const MovementMath = preload("res://movement_math.gd")


func test_no_input_means_no_movement() -> void:
	assert_eq(MovementMath.direction(false, false, false, false), Vector3.ZERO)


func test_opposite_actions_cancel() -> void:
	assert_eq(MovementMath.direction(true, true, true, true), Vector3.ZERO)


func test_forward_is_negative_z() -> void:
	assert_eq(MovementMath.direction(false, false, true, false), Vector3.FORWARD)


func test_diagonal_is_normalized() -> void:
	var direction := MovementMath.direction(false, true, true, false)
	assert_almost_eq(direction.length(), 1.0, 0.0001)
	assert_true(direction.x > 0.0 and direction.z < 0.0)
