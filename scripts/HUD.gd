#HUD.gd
extends CanvasLayer

var max_cig_time := 90.0

@export var player : Node

@onready var messagebox = $Messagebox
@onready var cig := $CigaretteBarContainer/CigMask
@onready var burn_tip := $CigaretteBarContainer/BurnTip
@onready var smoke = $CigaretteBarContainer/Smoke
@onready var cig_counter = $CigaretteBarContainer/CigCounter
@onready var ammo_count = $Inventory/AmmoCount
@onready var pause_menu = $PauseMenu
@onready var reload_sound = $Reload

var cig_count := 0
var cig_full_width := 0.0
var cig_is_empty := false
var cig_time



func _ready():
	# Store full widths for scaling
	pause_menu.visible = false
	cig_full_width = cig.size.x
	cig_count = GameState.cig_count
	cig_time = GameState.cig_time
func _process(delta):
	var selected_item = Inventory.get_selected()
	if Inventory.interaction_locked:
		return
	#--- Pause Menu --- 
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		pause_menu.visible = true
		$PauseMenu/Buttons/Resume.grab_focus()
	# --- Cigarette timer ---
	cig_counter.text = str(cig_count)
	cig_time -= delta
	cig_time = clamp(cig_time, 0, max_cig_time)
	var percent = cig_time / max_cig_time
	cig.size.x = cig_full_width * percent
	burn_tip.position.x = cig.position.x + cig.size.x
	smoke.position.x = burn_tip.position.x + 5
	
	if selected_item.id == "gun" or selected_item.id == "ammo":
		ammo_count.visible = true
	else:
		ammo_count.visible = false
	
	if cig_time > 0:
		#smoke.emitting = true
		burn_tip.visible = true
		cig_is_empty = false
		
	else:
		#smoke.emitting = false
		smoke.visible = false
		burn_tip.visible = false
		
	if cig_time == 0 and not cig_is_empty:
		cig_is_empty = true
		messagebox.show_message("My cigarette ran out.")
		
	if Input.is_action_just_pressed("use") and not Inventory.interaction_locked:
		print("used ", selected_item.id)
		match selected_item.id: 
			"lighter":			
				if cig_count > 0:
					messagebox.show_option("Light another one?")
					messagebox.confirmed.connect(relight_cig, CONNECT_ONE_SHOT)
				else:
					messagebox.show_message("It looks like i'm out of cigarettes.")
			"ammo":
				player.ammo+=12
				reload_sound.play()
				Inventory.remove_item(selected_item)
			
	ammo_count.text = str(player.ammo)
		
func take_damage(amount: float) -> void:
	if cig_time > 0:
		cig_time -= amount
		cig_time = clamp(cig_time, 0.0, max_cig_time)
		print("take damage")
	else:
		player.die()
		
func _unhandled_input(event):
	if Inventory.interaction_locked:
		return  # do nothing
	if event.is_action_pressed("use"):
		var selected_item = Inventory.get_selected()
		match selected_item.id:
			"full":
				messagebox.show_message("It's a charm of a full moon.")
			"crescent":
				messagebox.show_message("It's a charm of a crescent moon.")
			"gibbous":
				messagebox.show_message("It's a charm of a gibbous moon.")
	
func relight_cig(result: bool):
	if result:
		cig_time = max_cig_time
		smoke.visible = true
		cig_count -= 1
		player.play_relight_animation()
