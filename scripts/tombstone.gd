extends Node3D

@export var player: Node3D
@export var HUD: CanvasLayer
@export var puzzle_tombstone = false
@export var MAP: Node3D

@onready var click : AudioStreamPlayer3D

var in_contact := false
var can_interact := true
var click_count := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if puzzle_tombstone:
		click = AudioStreamPlayer3D.new()
		click.stream = preload("res://assets/sounds/click.mp3")
		click.volume_db = -7.5
		add_child(click)
	else:
		click = null


func _process(_delta: float) -> void:
	
	if player.velocity == Vector3.ZERO and Input.is_action_just_pressed("interact") and in_contact and can_interact:
		can_interact = false
		HUD.messagebox.show_option("Push Tombstone?")
		HUD.messagebox.confirmed.connect(push_tombstone, CONNECT_ONE_SHOT)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		in_contact = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		in_contact = false

func push_tombstone(result: bool):
	if result:
		if puzzle_tombstone:
			get_tree().paused = false
			click.play()
			get_tree().create_timer(0.3)
			HUD.messagebox.show_message("The tombstone clicked into place.")
			MAP.click_count += 1
			print(str(MAP.click_count))
		else:
			HUD.messagebox.show_message("It won't budge.")
			while HUD.messagebox.is_showing:
				await get_tree().process_frame
			can_interact = true

	
