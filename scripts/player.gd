# Player.gd
extends CharacterBody3D

@export var speed := 50.0
@export var gravity := 9.8

@export var bullet_scene: PackedScene
@export var shoot_cooldown := 0.85
@onready var ammo = 0

@onready var camera = $SpringArm3D/Camera3D
@onready var gunshot = $GunShot
@onready var inventory_swap = $InventorySwap
@onready var player_model = $PlayerModel

var camera_clamp := 0.20  # max vertical tilt in radians
var camera_rotation := 0.0

var can_shoot := false
var is_aiming := false

func _ready():
	can_shoot = true  

func _physics_process(delta):
	is_aiming = Input.is_action_pressed("aim") and Inventory.get_selected().id == "gun"
	# --- Movement Input ---
	if is_aiming:
		velocity.x = 0
		velocity.z = 0
	else:
		var input_dir = Vector2.ZERO
		input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_dir.y = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

		var input_strength = input_dir.length()
		if input_strength > 0:
			input_dir = input_dir.normalized()

		var direction = transform.basis.x * input_dir.x + transform.basis.z * input_dir.y
		velocity.x = direction.x * speed * input_strength
		velocity.z = direction.z * speed * input_strength
	handle_movement_animation(velocity)
	# --- Gravity ---
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
		
	#-- Inventory Controls ---
	if Input.is_action_just_pressed("next_item"):
		inventory_swap.play()
		Inventory.next_item()

	if Input.is_action_just_pressed("prev_item"):
		inventory_swap.play()
		Inventory.prev_item()

	# --- Controller Horizontal Look ---
	var look_input_x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	rotate_y(-look_input_x * 2 * PlayerSettings.sensitivity * delta)

	# --- Vertical Camera Look ---
	var look_input_y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	camera_rotation -= look_input_y * 2 / 4 * PlayerSettings.sensitivity * delta

	# --- Shoot ---
	if is_aiming and Input.is_action_just_pressed("shoot") and ammo > 0 and can_shoot:
		shoot()

	# --- Move ---
	move_and_slide()
	
	
func shoot():
	ammo-=1
	can_shoot = false

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_transform.origin = global_transform.origin + -transform.basis.z * 1.5 + Vector3.UP * -0.5
	gunshot.play()

	# Get horizontal direction only
	var direction = -transform.basis.z
	direction.y = 0
	direction = direction.normalized()
	bullet.direction = direction

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
	
func handle_movement_animation(v):
	var animation_player = player_model.get_node("AnimationPlayer")
	if is_aiming:
		animation_player.play("Aim")
	elif !velocity:
		animation_player.play("mixamo_com")
	elif velocity:
		animation_player.play("Walk")
