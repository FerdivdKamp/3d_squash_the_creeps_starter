extends RefCounted


## Convert four movement actions into a direction with a maximum length of one.
static func direction(left: bool, right: bool, forward: bool, back: bool) -> Vector3:
	var result := Vector3(
		int(right) - int(left),
		0.0,
		int(back) - int(forward)
	)
	return result.normalized()
