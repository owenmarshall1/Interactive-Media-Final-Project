extends CanvasLayer

@onready var panel = $Panel
@onready var label = $Panel/Label
@onready var button_yes = $Panel/Yes
@onready var button_no = $Panel/No

var is_showing := false
var choice_callback = null
	
func _ready():
	panel.visible = false
	button_yes.visible = false
	button_no.visible = false
	

func show_message(text: String, pause=true):
	if is_showing:
		return
	
	panel.visible = true
	is_showing = true
	label.text = ""
	button_yes.visible = false
	button_no.visible = false
	
	if pause:
		get_tree().paused = true
		
	# Typewriter effect
	for i in text.length():
		label.text += text[i]
		await get_tree().create_timer(0.05).timeout
		# Exit early if player presses interact
		if Input.is_action_just_pressed("interact"):
			label.text = text
			break

	# Wait before hiding
	while not Input.is_action_just_pressed("interact"):
		await get_tree().process_frame

	panel.visible = false
	is_showing = false
	get_tree().paused = false
