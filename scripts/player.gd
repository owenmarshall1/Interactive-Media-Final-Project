# Player.gd
extends CharacterBody3D

@export var speed := 6.0
@export var gravity := 9.8
@export var HUD: CanvasLayer

@export var bullet_scene: PackedScene
@export var shoot_cooldown := 0.85
@onready var ammo = 0

@onready var camera = $SpringArm3D/Camera3D
@onready var player_model = $PlayerModel

#sounds
@onready var inventory_swap = $InventorySwap
@onready var footstep_audio = $FootstepGrass
@onready var relight_sound = $RelightSound
@onready var gunshot = $GunShot

var footstep_timer := 0.0
var footstep_interval := 0.6

var camera_clamp := 0.20  # max vertical tilt in radians
var camera_rotation := 0.0

var can_move := true
var can_shoot := false
var is_aiming := false
var is_playing_oneshot := false

func _ready():
	can_shoot = true
	ammo = GameState.ammo

func _physics_process(delta):
	if Inventory.get_selected().id == "gun":
		$PlayerModel/Armature/Skeleton3D/BoneAttachment3D/PSX_Colt1911.visible = true	
	else:
		$PlayerModel/Armature/Skeleton3D/BoneAttachment3D/PSX_Colt1911.visible = false
		
	is_aiming = Input.is_action_pressed("aim") and Inventory.get_selected().id == "gun"
	# --- Movement Input ---
	if is_aiming:
		velocity.x = 0
		velocity.z = 0
	elif can_move:
		var input_dir = Vector2.ZERO
		input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_dir.y = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

		var input_strength = input_dir.length()
		if input_strength > 0:
			input_dir = input_dir.normalized()

		var direction = transform.basis.x * input_dir.x + transform.basis.z * input_dir.y
		velocity.x = direction.x * speed * input_strength
		velocity.z = direction.z * speed * input_strength
		
	handle_footsteps(delta)
	handle_rotation(delta)
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
	camera_rotation = clamp(camera_rotation, -camera_clamp, camera_clamp)
	camera.rotation.x = camera_rotation      

	# --- Shoot ---
	if is_aiming and Input.is_action_just_pressed("shoot") and ammo > 0 and can_shoot:
		shoot()

	# --- Move ---
	move_and_slide()
	
func take_damage(amount: float) -> void:
	HUD.take_damage(amount)
	
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
	
var aim_settled := false

func handle_rotation(_delta):
	# Aiming → face camera forward
	if is_aiming:
		var forward = -transform.basis.z
		forward.y = 0
		
		if forward.length() > 0.001:
			var target_pos = player_model.global_position + forward
			player_model.look_at(target_pos, Vector3.UP)
			player_model.rotate_y(PI)  # ← flip 180°
		return

	# Moving → face movement direction
	var move_dir = Vector3(velocity.x, 0, velocity.z)

	if move_dir.length() > 0.1:
		move_dir = move_dir.normalized()
		var target_pos = player_model.global_position + move_dir
		player_model.look_at(target_pos, Vector3.UP)
		player_model.rotate_y(PI)  # ← flip 180°
		
func handle_movement_animation(_direction):
	if is_playing_oneshot:
		return
	var animation_player = player_model.get_node("AnimationPlayer")
	if is_aiming:
		if not aim_settled and animation_player.current_animation != "Aim":
			animation_player.play("Aim", -1, 6.0)
			animation_player.animation_finished.connect(_on_aim_in_finished, CONNECT_ONE_SHOT)
	else:
		aim_settled = false
		if velocity.length() == 0:
			animation_player.play("mixamo_com")
		else:
			animation_player.play("Walk", -1, 0.75)

func _on_aim_in_finished(anim_name: String):
	if anim_name == "Aim":
		aim_settled = true
		player_model.get_node("AnimationPlayer").pause()
		
func play_relight_animation():
	var animation_player = player_model.get_node("AnimationPlayer")
	is_playing_oneshot = true
	can_move = false
	velocity = Vector3.ZERO
	aim_settled = false
	animation_player.play("Relight")
	relight_sound.play()
	animation_player.animation_finished.connect(_on_relight_finished, CONNECT_ONE_SHOT)

func _on_relight_finished(anim_name: String):
	if anim_name == "Relight":
		can_move = true
		is_playing_oneshot = false
		handle_movement_animation(velocity)
		
func handle_footsteps(delta):
	# Only play when moving and on ground
	var is_moving = Vector3(velocity.x, 0, velocity.z).length() > 0.1
	
	if is_moving and is_on_floor() and not is_aiming:
		footstep_timer -= delta
		footstep_audio.pitch_scale = randf_range(0.7, 1.3)
		if footstep_timer <= 0:
			footstep_audio.play()
			footstep_timer = footstep_interval
	else:
		footstep_timer = 0
		
func die():
	can_move = false
	can_shoot = false
	is_playing_oneshot = true
	velocity = Vector3.ZERO
	var animation_player = player_model.get_node("AnimationPlayer")
	animation_player.play("Death")
	await animation_player.animation_finished
	$AnimationPlayer/ColorRect.visible = true
	$AnimationPlayer.play("deathfade")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer/ColorRect.visible = false
	Engine.get_main_loop().change_scene_to_file("res://scenes/Main_menu.tscn")
