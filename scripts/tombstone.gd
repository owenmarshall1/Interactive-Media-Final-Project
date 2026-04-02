extends Node3D

@export var player: Node3D
@export var messagebox: CanvasLayer
@export var puzzle_tombstone = false

var in_contact := false
var can_interact := true

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if player.velocity == Vector3.ZERO and Input.is_action_just_pressed("interact") and in_contact and can_interact:
		can_interact = false
		messagebox.show_option("Push Tombstone?")
		messagebox.confirmed.connect(push_tombstone, CONNECT_ONE_SHOT)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		in_contact = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		in_contact = false

func push_tombstone(result: bool):
	if result:
		if puzzle_tombstone:
			pass
		else:
			messagebox.show_message("It won't budge.")
	while messagebox.is_showing:
		await get_tree().process_frame
	can_interact = true

	
