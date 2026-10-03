extends GutTest

const PLAYER_SCENE = preload("res://player.tscn")
const MOB_SCENE = preload("res://mob.tscn")


func test_player_scene_has_gameplay_pivot_and_collision() -> void:
	var player = autofree(PLAYER_SCENE.instantiate())
	assert_not_null(player.get_node_or_null("Pivot"))
	assert_not_null(player.get_node_or_null("CollisionShape3D"))
	assert_true(player.speed > 0.0)


func test_player_dash_locks_direction_for_a_short_burst() -> void:
	var player = autofree(PLAYER_SCENE.instantiate())
	add_child(player)
	Input.action_press("move_right")
	Input.action_press("dash")
	player._physics_process(0.016)
	assert_almost_eq(player.target_velocity.x, player.speed * player.dash_speed_multiplier, 0.001)

	Input.action_release("move_right")
	Input.action_release("dash")
	player._physics_process(0.05)
	assert_almost_eq(player.target_velocity.x, player.speed * player.dash_speed_multiplier, 0.001)

	player._physics_process(player.dash_duration)
	assert_almost_eq(player.target_velocity.x, 0.0, 0.001)


func test_dash_is_mapped_to_shift_and_right_trigger() -> void:
	var has_shift := false
	var has_right_trigger := false
	for event in InputMap.action_get_events("dash"):
		if event is InputEventKey and event.keycode == KEY_SHIFT:
			has_shift = true
		if event is InputEventJoypadMotion and event.axis == JOY_AXIS_TRIGGER_RIGHT and event.axis_value > 0.0:
			has_right_trigger = true
	assert_true(has_shift)
	assert_true(has_right_trigger)


func test_mob_initialize_sets_position_and_bounded_horizontal_speed() -> void:
	var mob = autofree(MOB_SCENE.instantiate())
	mob.initialize(Vector3(6.0, 0.0, 0.0), Vector3.ZERO)

	assert_almost_eq(mob.position.distance_to(Vector3(6.0, 0.0, 0.0)), 0.0, 0.0001)
	assert_between(mob.velocity.length(), float(mob.minimal_speed), float(mob.maximum_speed))
	assert_almost_eq(mob.velocity.y, 0.0, 0.0001)
