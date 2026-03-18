extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 5.0
@export var mouse_sensitivity := 0.002
@export var controller_sensitivity := 3.0
@export var gravity := 9.8

var camera_rotation := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	# Mouse look
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		camera_rotation -= event.relative.y * mouse_sensitivity
		camera_rotation = clamp(camera_rotation, -1.5, 1.5)
		$Camera3D.rotation.x = camera_rotation

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

	# --- JUMP ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# --- CONTROLLER CAMERA ---
	var look_input = Vector2.ZERO
	look_input.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	look_input.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")

	# Horizontal rotation (player)
	rotate_y(-look_input.x * controller_sensitivity * delta)

	# Vertical rotation (camera)
	camera_rotation -= look_input.y * controller_sensitivity * delta
	camera_rotation = clamp(camera_rotation, -1.5, 1.5)
	$Camera3D.rotation.x = camera_rotation

	# --- MOVE ---
	move_and_slide()
