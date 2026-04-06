extends CanvasLayer

signal confirmed(result: bool)

@onready var panel = $Panel
@onready var label = $Panel/Label
@onready var button_yes = $Panel/Yes
@onready var button_no = $Panel/No
@onready var inventory = $"../Inventory"

var is_showing := false
var text_speed = 0.035

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	panel.visible = false
	button_yes.visible = false
	button_no.visible = false

	button_yes.pressed.connect(_on_yes_pressed)
	button_no.pressed.connect(_on_no_pressed)

# -------------------------
# MESSAGE ONLY (no options)
# -------------------------
func show_message(text: String, pause := true):
	if is_showing:
		return
	
	inventory.visible = false
	panel.visible = true
	is_showing = true
	label.text = ""

	if pause:
		get_tree().paused = true

	# Typewriter effect
	for i in text.length():
		label.text += text[i]
		if text[i] == "\n":
			await get_tree().create_timer(0.75).timeout
		else:
			await get_tree().create_timer(text_speed).timeout
		
		if Input.is_action_just_pressed("interact"):
			label.text = text
			break

	# Wait for confirm
	await _wait_for_accept()

	_close()

# -------------------------
# YES / NO OPTION
# -------------------------
func show_option(text: String):
	if is_showing:
		return
	
	inventory.visible = false
	panel.visible = true
	is_showing = true
	label.text = ""

	get_tree().paused = true

	# Typewriter
	for i in text.length():
		label.text += text[i]
		if text[i] == "\n":
			await get_tree().create_timer(0.75).timeout
		else:
			await get_tree().create_timer(text_speed).timeout
		
		if Input.is_action_just_pressed("interact"):
			label.text = text
			break

	# SHOW BUTTONS
	button_yes.visible = true
	button_no.visible = true
	button_yes.grab_focus()

# -------------------------
# BUTTON HANDLERS
# -------------------------
func _on_yes_pressed():
	_emit_and_close(true)

func _on_no_pressed():
	_emit_and_close(false)

# -------------------------
# HELPERS
# -------------------------
func _emit_and_close(result: bool):
	_close()
	emit_signal("confirmed", result)

func _close():
	panel.visible = false
	button_yes.visible = false
	button_no.visible = false
	is_showing = false
	inventory.visible = true

	get_tree().paused = false

func _wait_for_accept():
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("interact"):
			return
