extends VBoxContainer

const GRAVEYARD = preload("res://scenes/Graveyard.tscn")

func _on_start_button_pressed():
	get_tree().change_scene_to_packed(GRAVEYARD)
	
func _on_quit_pressed():
	get_tree().quit()
