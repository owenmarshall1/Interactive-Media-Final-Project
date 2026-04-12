extends CharacterBody3D

const SPEED = 4.8
const ATTACK_DAMAGE = 10.0
const ATTACK_RANGE = 4.0
const ATTACK_COOLDOWN = 1.6

var cutscene_mode = false
var player: Node = null
var health := 50.0
var can_attack := true
var attacking := false
var dead := false
var player_detected := false
var player_in_range := false
var lunging := false
var is_screaming := false

@export var player_path: NodePath
@export var game_manager: Node
@export var moon: bool
@onready var nav_agent = $NavigationAgent3D
@onready var detection_area = $DetectionArea
@onready var anim_player = $EnemyModel/AnimationPlayer
@onready var model = $EnemyModel

#sounds
@onready var munch_sound = $Sounds/Munch
@onready var scream_sound = $Sounds/Scream
@onready var death_sound = $Sounds/Death

func _ready() -> void:
	if player_path:
		player = get_node(player_path)
	anim_player.play("Idle")
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	if dead or cutscene_mode:
		return

	handle_rotation()

	if !player_detected:
		# Not yet detected — just idle, wait for detection area
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if attacking:
		if lunging:
			move_and_slide()
		else:
			#velocity = Vector3.ZERO
			move_and_slide()
		return
	if not is_instance_valid(player): return
	var dist = global_position.distance_to(player.global_position)

	if dist <= ATTACK_RANGE and can_attack and !cutscene_mode:
		attack()
	elif player_in_range:
		# Chase the player
		nav_agent.set_target_position(player.global_position)
		var next_nav_point = nav_agent.get_next_path_position()
		var move_dir = (next_nav_point - global_position)
		move_dir.y = 0
		velocity = move_dir.normalized() * SPEED
		if anim_player.current_animation != "Walk":
			anim_player.play("Walk", -1, 2.0)
	else:
		# Player left range, stop
		velocity = Vector3.ZERO
		if anim_player.current_animation != "Idle":
			anim_player.play("Idle")

	move_and_slide()

func _die() -> void:
	dead = true
	velocity = Vector3.ZERO
	death_sound.play()
	if randi_range(0, 1) == 0:
		anim_player.play("FallBackDead")
	else:
		anim_player.play("FallDead")
	set_physics_process(false)
	$CollisionShape3D.disabled = true

func attack() -> void:
	if cutscene_mode: return
	can_attack = false
	attacking = true
	anim_player.play("Attack", -1 , 1.5)
	
	#lunge
	var lunge_dir = (player.global_position - global_position).normalized()
	lunge_dir.y = 0
	velocity = lunge_dir * 10.0  # burst of speed toward player
	await get_tree().create_timer(0.4).timeout  # lunge duration
	if dead or not is_instance_valid(player): return
	lunging = false
	velocity = Vector3.ZERO
	
	await get_tree().create_timer(0.3).timeout
	if dead: return
	var dist = global_position.distance_to(player.global_position)
	if dist <= ATTACK_RANGE:
		player.take_damage(ATTACK_DAMAGE)
		
	await get_tree().create_timer(ATTACK_COOLDOWN - 0.5).timeout
	if dead or not is_instance_valid(player): return
	attacking = false
	can_attack = true
	if anim_player.current_animation != "Walk":
		anim_player.play("Walk", -1, 2.0)

func take_damage(damage: float) -> void:
	health -= damage
	if !player_detected and !is_screaming and !moon:
		_trigger_scream()
	if health <= 0 and !dead:
		_die()

func handle_rotation() -> void:
	if player == null or not is_instance_valid(player):
		return
	var dir = player.global_position - model.global_position
	dir.y = 0
	if dir.length() > 0.001:
		model.look_at(model.global_position + dir, Vector3.UP)
		model.rotate_y(PI)

func _on_body_entered(body: Node) -> void:
	if body == player:
		player_in_range = true
		if !player_detected and !is_screaming:
			_trigger_scream()

func _on_body_exited(body: Node) -> void:
	if body == player:
		player_in_range = false

func _trigger_scream() -> void:
	if is_screaming:
		return
	is_screaming = true
	scream_sound.play()
	anim_player.play("Scream")
	await anim_player.animation_finished
	if dead: return
	is_screaming = false
	player_detected = true
	player_in_range = true
	
func play_cutscene_animation():
	munch_sound.play()
	anim_player.play("Bite")
	await anim_player.animation_finished
	_trigger_scream()
	await get_tree().create_timer(2.5).timeout
	player.get_node("SpringArm3D/Camera3D").current = true
	player.can_move = true
