extends CanvasLayer

@export var max_cig_time := 180.0
var cig_time := 180.0

@onready var messagebox = $Messagebox

@onready var cig := $CigaretteBarContainer/CigMask
@onready var burn_tip := $CigaretteBarContainer/BurnTip
@onready var smoke = $CigaretteBarContainer/Smoke
@onready var cig_counter = $CigaretteBarContainer/CigCounter

var cig_count := 3
var cig_full_width := 0.0
var cig_is_empty := false

func _ready():
	# Store full widths for scaling
	cig_full_width = cig.size.x
	

func _process(delta):
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
		
	if cig_time <= 0 and not cig_is_empty:
		cig_is_empty = true
		messagebox.show_message("My cigarette ran out.")
		
	if Input.is_action_just_pressed("relight"):
		if cig_count > 0:
			messagebox.show_option("Light another one?")
			messagebox.confirmed.connect(relight_cig, CONNECT_ONE_SHOT)
		else:
			messagebox.show_message("It looks like i'm out of cigarettes.")
		
	
func take_damage(amount):
	return

func relight_cig(result: bool):
	if result:
		cig_time = max_cig_time
		smoke.visible = true
		cig_count-=1
