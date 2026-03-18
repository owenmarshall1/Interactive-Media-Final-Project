extends Node3D

@export var target: Node3D
@export var follow_speed := 5.0

func _process(delta):
	if target:
		var target_pos = target.global_transform.origin
		global_transform.origin = global_transform.origin.lerp(target_pos, follow_speed * delta)
