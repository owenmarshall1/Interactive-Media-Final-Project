extends CharacterBody3D

var player = null
const SPEED = 3.0
var health = 60.0
var player_in_range = false


@export var player_path : NodePath
@onready var nav_agent = $NavigationAgent3D
@onready var detection_area = $DetectionArea

func _ready() -> void:
	player = get_node(player_path)
	
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	
func _physics_process(delta: float) -> void:	
	if player_in_range:
		nav_agent.set_target_position(player.global_position)
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_position).normalized() * SPEED
	
	move_and_slide()
	
	if health <= 0:
		queue_free()
		return

func take_damage(damage):
	health -= damage
	print(health)
	
func _on_body_entered(body: Node) -> void:
	if body == player:
		player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body == player:
		player_in_range = false
