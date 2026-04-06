extends Node3D

@export var player: Node3D
@export var HUD: Node

var entrance_door = false
var exit_door = false
var can_exit = false
var can_interact := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and entrance_door and can_interact:
		can_interact = false
		HUD.messagebox.show_message("I can't go back out there.")
		while HUD.messagebox.is_showing:
			await get_tree().process_frame
		can_interact = true
		
	if Input.is_action_just_pressed("interact") and exit_door and can_interact and !can_exit:
		can_interact = false
		HUD.messagebox.show_message("Beneath the pale and patient face of the moon,\na watcher crowned in dust older than light.\nThe moon is not a mirror, it is an eye.")
		while HUD.messagebox.is_showing:
			await get_tree().process_frame
		$Cutscene/AnimationPlayer.play("cutscene")
		$Cutscene/ColorRect.visible = true
		$Cutscene/Camera3D.current = true
		await get_tree().create_timer(3).timeout
		$Cutscene/Camera3D2.current = true
		await get_tree().create_timer(7).timeout
		can_interact = true
		can_exit = true
		$Player.get_node("SpringArm3D/Camera3D").current = true
		
	if Input.is_action_just_pressed("interact") and exit_door and can_exit:
		HUD.messagebox.show_option("Jump down the hole?")
		HUD.messagebox.confirmed.connect(jump, CONNECT_ONE_SHOT)


func jump(result: bool):
	if result:
		GameState.ammo = player.ammo
		GameState.cig_count = HUD.cig_count
		GameState.cig_time = HUD.cig_time
		get_tree().change_scene_to_file("res://scenes/Environment/Backyard.tscn")
	

func _on_church_door_body_entered(body: Node3D) -> void:
	if body == player:
		entrance_door = true


func _on_church_door_body_exited(body: Node3D) -> void:
	if body == player:
		entrance_door = false


func _on_exit_body_entered(body: Node3D) -> void:
	if body == player:
		exit_door = true


func _on_exit_body_exited(body: Node3D) -> void:
	if body == player:
		exit_door = false
