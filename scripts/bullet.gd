# Bullet.gd
extends CharacterBody3D

@export var speed := 20.0
@export var lifetime := 2.0
var direction := Vector3.ZERO

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	velocity = direction * speed
	move_and_slide()
	if get_slide_collision_count() > 0:
		queue_free()
