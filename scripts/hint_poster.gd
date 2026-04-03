extends CSGBox3D

@export var player: Node3D

@onready var poster = $"../../../../HUD/HintPoster"
@onready var page_sound = $"../../../../HUD/HintPoster/PosterSound"

var in_contact = false
var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	page_sound.process_mode = Node.PROCESS_MODE_ALWAYS
	poster.visible = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and in_contact:
		if not is_open:
			# OPEN
			page_sound.play()
			get_tree().paused = true
			poster.visible = true
			is_open = true
		else:
			# CLOSE
			get_tree().paused = false
			poster.visible = false
			is_open = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		in_contact = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		in_contact = false
