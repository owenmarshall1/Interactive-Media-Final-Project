extends Node3D

@export var player: Node3D
@onready var messagebox = $HUD/Messagebox2

var click_count = 0
var church_unlocked = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if click_count >= 3 and not church_unlocked:
		messagebox.show_message("You hear something unlock.")
		church_unlocked = true
