extends CanvasLayer

@export var max_health := 100
var current_health := 100

@export var max_cig_time := 180.0
var cig_time := 180.0

@onready var messagebox = $Messagebox

@onready var health_bar := $HealthBarContainer/HealthBar
@onready var cig := $CigaretteBarContainer/CigMask
@onready var burn_tip := $CigaretteBarContainer/BurnTip
@onready var smoke = $CigaretteBarContainer/Smoke


var health_bar_full_width := 0.0
var cig_full_width := 0.0
var cig_is_empty := false

func _ready():
	# Store full widths for scaling
	health_bar_full_width = health_bar.size.x
	cig_full_width = cig.size.x

func _process(delta):
	# --- Health bar ---
	var health_percent = clamp(current_health / max_health, 0, 1)
	health_bar.size.x = health_bar_full_width * health_percent

	# --- Cigarette timer ---
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
	
func take_damage(amount):
	current_health = clamp(current_health - amount, 0, max_health)

func relight_cig():
	cig_time = max_cig_time
	await get_tree().create_timer(0.5).timeout
	smoke.visible = true
