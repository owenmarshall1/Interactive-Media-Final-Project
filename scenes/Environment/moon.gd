extends Node3D

@onready var moonlord = $MoonLord
@onready var HUD = $HUD

var text = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moonlord.dead == true and !text:
		await get_tree().create_timer(0.3).timeout
		HUD.messagebox.show_message("Finally...\nSomeone to take my place...\nThe moon sees everything...")
		text = true
	pass
