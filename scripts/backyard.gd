extends Node3D

@export var HUD: CanvasLayer

var correct_charm_count = 0
var cave_unlocked = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if correct_charm_count >= 3 and not cave_unlocked:
			HUD.messagebox.show_message("You hear something unlock.")
			cave_unlocked = true
