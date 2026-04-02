extends VBoxContainer

@onready var scene_transistion = $"../scene_transition/AnimationPlayer"

const GRAVEYARD = preload("res://scenes/Graveyard.tscn")
func _ready():
	$start.grab_focus()
	
func _on_start_button_pressed():
	scene_transistion.play("dissolve")
	await scene_transistion.animation_finished
	scene_transistion.play_backwards("dissolve")
	get_tree().change_scene_to_packed(GRAVEYARD)
	
	
func _on_quit_pressed():
	get_tree().quit()
