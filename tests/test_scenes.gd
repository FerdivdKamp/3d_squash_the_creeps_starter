extends GutTest

const PLAYER_SCENE = preload("res://player.tscn")
const MOB_SCENE = preload("res://mob.tscn")


func test_player_scene_has_gameplay_pivot_and_collision() -> void:
	var player = autofree(PLAYER_SCENE.instantiate())
	assert_not_null(player.get_node_or_null("Pivot"))
	assert_not_null(player.get_node_or_null("CollisionShape3D"))
	assert_true(player.speed > 0.0)


func test_mob_initialize_sets_position_and_bounded_horizontal_speed() -> void:
	var mob = autofree(MOB_SCENE.instantiate())
	mob.initialize(Vector3(6.0, 0.0, 0.0), Vector3.ZERO)

	assert_almost_eq(mob.position.distance_to(Vector3(6.0, 0.0, 0.0)), 0.0, 0.0001)
	assert_between(mob.velocity.length(), float(mob.minimal_speed), float(mob.maximum_speed))
	assert_almost_eq(mob.velocity.y, 0.0, 0.0001)
