extends VBoxContainer

@onready var scene_transistion = $"../../scene_transition/AnimationPlayer"

var controls_showing = false

const GRAVEYARD = preload("res://scenes/Graveyard.tscn")
func _ready():
	$start.grab_focus()

func _process(_delta: float) -> void:
	if controls_showing and Input.is_action_just_pressed("pause"):
		$start.grab_focus()
		$"../Controls".visible = false
		controls_showing = false
		
func _on_start_button_pressed():
	scene_transistion.play("dissolve")
	await scene_transistion.animation_finished
	scene_transistion.play_backwards("dissolve")
	get_tree().change_scene_to_packed(GRAVEYARD)
	
	
func _on_quit_pressed():
	get_tree().quit()


func _on_options_pressed() -> void:
	controls_showing = true
	$"../Controls".show()
