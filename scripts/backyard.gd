extends Node3D

@export var HUD: CanvasLayer
@export var player: Node3D
@export var camera: Camera3D

@onready var open_door_animation = $Cave/Camera3D/DoorOpen
@onready var cutscene_camera = $Cave/Camera3D
@onready var scene_fade = $Cave/Camera3D/fade
@onready var scene_transition = $Cave/LightBeam/Fade
@onready var player_camera = player.get_node("SpringArm3D/Camera3D")

var correct_charm_count = 0
var cave_unlocked = false
var in_contact_with_lightbeam = false

var rng = RandomNumberGenerator.new()
var shaking := false
var shake_strength := 0.0
var shake_duration := 4.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if shaking:
		player_camera.h_offset = rng.randf_range(-shake_strength, shake_strength)
		player_camera.v_offset = rng.randf_range(-shake_strength, shake_strength)
	else:
		player_camera.h_offset = 0.0
		player_camera.v_offset = 0.0
	
	#Charm puzzle and cutscene
	if correct_charm_count >= 1 and not cave_unlocked:
		cutscene_camera.current = true
		HUD.visible = false
		open_door_animation.play("open")
		await open_door_animation.animation_finished
		await get_tree().process_frame  
		scene_fade.visible = false
		HUD.visible = true
		cutscene_camera.current = false
		cave_unlocked = true
		
func _on_lightbeam_entered(body: Node3D) -> void:
	if body == player:
		scene_transition.play("Fade")
		shaking = true
		shake_strength = 0.5
		await get_tree().create_timer(shake_duration).timeout
		shaking = false
		await scene_transition.animation_finished
		get_tree().change_scene_to_file("res://scenes/Environment/moon.tscn")
