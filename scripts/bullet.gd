extends CharacterBody3D

@export var speed := 40.0
@export var lifetime := 2.0
var direction := Vector3.ZERO

func _ready():
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(_delta):
	velocity = direction * speed
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body and body.has_method("take_damage"):
			body.take_damage(10)
		queue_free()
		return
