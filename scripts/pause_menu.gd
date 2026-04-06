extends Control

@onready var pause_menu = $"."
@onready var scene_transistion = $scene_transition/AnimationPlayer

var controls_showing = false

const MENU = preload("res://scenes/Main_menu.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if controls_showing and Input.is_action_just_pressed("pause"):
		$Buttons/Resume.grab_focus()
		$Controls.visible = false
		controls_showing = false


func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false


func _on_return_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false
	scene_transistion.play("dissolve")
	await scene_transistion.animation_finished
	await get_tree().process_frame
	GameState.reset()
	Inventory.items.clear()
	Inventory.selected_index = 0
	get_tree().change_scene_to_file("res://scenes/Main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_controls_pressed() -> void:
	controls_showing = true
	$Controls.show()
