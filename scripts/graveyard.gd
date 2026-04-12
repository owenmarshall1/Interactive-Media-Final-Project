extends Node3D

@export var player: Node3D
@export var HUD: CanvasLayer
@export var enemy_scene: PackedScene

@onready var first_cutscene_player = $FirstCutscene/AnimationPlayer

var cutscene = false
var click_count = 0
var first_cutscene_activated = false
var church_unlocked = false
var church_door_contact = false
var spawned_enemies := []

@onready var enemy_spawn_points= [
	$Enemies/enemyspawns/Node3D2,
	$Enemies/enemyspawns/Node3D,
	$Enemies/enemyspawns/Node3D3,
	$Enemies/enemyspawns/Node3D4,
	$Enemies/enemyspawns/Node3D5,
	$Enemies/enemyspawns/Node3D6,
	$Enemies/enemyspawns/Node3D7,
	$Enemies/enemyspawns/Node3D8,
	$Enemies/enemyspawns/Node3D9,
	$Enemies/enemyspawns/Node3D10
	]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if click_count >= 3 and not church_unlocked:
		HUD.messagebox.show_message("You hear the church door unlock.")
		church_unlocked = true
		church_cutscene()
		
	if Input.is_action_just_pressed("interact") and church_unlocked and church_door_contact:
		GameState.ammo = player.ammo
		GameState.cig_count = HUD.cig_count
		GameState.cig_time = HUD.cig_time
		for enemy in spawned_enemies:
			enemy.queue_free()
		get_tree().change_scene_to_file("res://scenes/Environment/Church.tscn")


func _on_first_cutscene_trigger_body_entered(body: Node3D) -> void:
	if body == player:
		if first_cutscene_activated: return
		cutscene = true
		first_cutscene_activated = true
		player.can_move = false
		player.velocity = Vector3.ZERO
		$FirstCutscene/ColorRect.visible = true
		first_cutscene_player.play("cutscene")
		$FirstCutscene/Camera1.current = true
		await get_tree().create_timer(2.0).timeout
		$FirstCutscene/Camera2.current = true
		
		$FirstCutscene/ColorRect.visible = false
		cutscene = false
		
func church_cutscene():
	player.invincible = true
	player.can_move = false
	player.velocity = Vector3.ZERO
	while HUD.messagebox.is_showing:
			await get_tree().process_frame
	$ChurchBellCutscene/AnimationPlayer.play("cutscene")
	$ChurchBellCutscene/Camera3D.current = true
	$ChurchBellCutscene/ColorRect.visible = true
	await get_tree().create_timer(4.5).timeout
	$ChurchBellCutscene/Camera3D2.current = true
	await get_tree().create_timer(4.5).timeout
	$ChurchBellCutscene/Camera3D3.current = true

	for point in enemy_spawn_points:
		var enemy = enemy_scene.instantiate()
		enemy.player = $Player
		enemy.game_manager = self
		enemy.cutscene_mode = true
		get_parent().add_child(enemy)
		enemy.global_position = point.global_position
		enemy._trigger_scream()
		spawned_enemies.append(enemy)
		
	await get_tree().create_timer(2).timeout
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.cutscene_mode = false
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.cutscene_mode = false
	$ChurchBellCutscene/ColorRect.visible = false
	player.can_move = true
	player.get_node("SpringArm3D/Camera3D").current = true
	await get_tree().create_timer(1).timeout
	player.invincible = false
	


func _on_church_door_entered(body: Node3D) -> void:
	if body == player:
		church_door_contact = true
		


func _on_church_door_exited(body: Node3D) -> void:
	if body == player:
		church_door_contact = false
