extends CharacterBody3D

@export var speed := 5.0
@export var controller_sensitivity := 2.0
@export var gravity := 9.8
@export var bullet_scene: PackedScene
@export var shoot_cooldown := 0.3

var camera_rotation := 0.0
var can_shoot := true

func _ready():
	pass

func _physics_process(delta):
	# --- MOVEMENT INPUT (keyboard + controller) ---
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

	var input_strength = input_dir.length()
	input_dir = input_dir.normalized()

	# Convert to 3D direction relative to player
	var direction = (transform.basis.x * input_dir.x + transform.basis.z * input_dir.y)

	# Apply movement (with analog speed)
	velocity.x = direction.x * speed * input_strength
	velocity.z = direction.z * speed * input_strength

	# --- GRAVITY ---
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# --- CONTROLLER CAMERA ---
	var look_input = Vector2.ZERO
	look_input.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	#look_input.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")

	# Horizontal rotation (player)
	rotate_y(-look_input.x * controller_sensitivity * delta)
	
	# --- SHOOT ---
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()

	# Vertical rotation (camera)
	camera_rotation -= look_input.y * controller_sensitivity * delta
	camera_rotation = clamp(camera_rotation, -1.5, 1.5)
	$CameraPivot/Camera3D.rotation.x = camera_rotation

	# --- MOVE ---
	move_and_slide()
	
func shoot():
	can_shoot = false
	var bullet = bullet_scene.instantiate()
	
	#spawn
	var spawn_pos = global_transform.origin + -transform.basis.z * 1.5 + Vector3.UP * 1.0
	bullet.global_transform.origin = spawn_pos
	
	bullet.direction = -transform.basis.z
	
	get_tree().current_scene.add_child(bullet)
	
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
	
	
	
	
	
	
	
	
	
