extends CanvasLayer

var max_cig_time := 60.0
var cig_time := 60.0

@export var player : Node

@onready var messagebox = $Messagebox

@onready var cig := $CigaretteBarContainer/CigMask
@onready var burn_tip := $CigaretteBarContainer/BurnTip
@onready var smoke = $CigaretteBarContainer/Smoke
@onready var cig_counter = $CigaretteBarContainer/CigCounter
@onready var ammo_count = $AmmoCount
@onready var pause_menu = $PauseMenu

var cig_count := 0
var cig_full_width := 0.0
var cig_is_empty := false


func _ready():
	# Store full widths for scaling
	pause_menu.visible = false
	cig_full_width = cig.size.x
	

func _process(delta):
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
		
	if Input.is_action_just_pressed("relight"):
		if cig_count > 0:
			messagebox.show_option("Light one?")
			messagebox.confirmed.connect(relight_cig, CONNECT_ONE_SHOT)
		else:
			messagebox.show_message("It looks like i'm out of cigarettes.")
			
	ammo_count.text = str(player.ammo)
		
	
func take_damage(_amount):
	return

func relight_cig(result: bool):
	if result:
		cig_time = max_cig_time
		smoke.visible = true
		cig_count-=1
