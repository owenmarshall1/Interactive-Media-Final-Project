extends Control
# ControlsScreen.gd
# Attach this to a Control node that fills the screen.
# Call show_controls() / hide_controls() from your pause menu or settings.

const CONTROLS = [
	["Walk", "WASD", "Left Stick"],
	["Look", "Arrow Keys", "Right Stick"],
	["ACTIONS", null],
	["Aim", "Shift / RMB", "LT"],
	["Shoot", "Space / LMB", "RT"],
	["Interact", "E", "◻ Button"],
	["Use Item", "F", "X Button"],
	["Cycle Items", "1 / 2", "LB / RB"],
	["MENU", null],
	["Pause", "Escape", "Start"],
]

# ── Colours ──────────────────────────────────────────────────────────────────
const COL_BG          := Color(0.04, 0.04, 0.06, 0.95)
const COL_PANEL       := Color(0.096, 0.096, 0.096, 1.0)
const COL_HEADER      := Color(1.0, 1.0, 1.0, 1.0)
const COL_LABEL       := Color(1.0, 1.0, 1.0, 1.0)
const COL_KEY         := Color(0.122, 0.122, 0.122, 1.0)
const COL_KEY_BORDER  := Color(0.0, 0.0, 0.0, 0.6)
const COL_SEPARATOR   := Color(1.0, 1.0, 1.0, 0.25)
const COL_TITLE       := Color(1.0, 1.0, 1.0, 1.0)
const COL_COLUMN_HDR  := Color(0.0, 0.0, 0.0, 0.7)

var _built := false

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	if _built:
		return
	_built = true

	anchor_right  = 1.0
	anchor_bottom = 1.0

	# ── Centred panel ────────────────────────────────────────────────────────
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 0)

	var style := StyleBoxFlat.new()
	style.bg_color                   = COL_PANEL
	style.border_width_left          = 1
	style.border_width_right         = 1
	style.border_width_top           = 1
	style.border_width_bottom        = 1
	style.border_color               = COL_KEY_BORDER
	style.content_margin_left        = 20
	style.content_margin_right       = 20
	style.content_margin_top         = 20
	style.content_margin_bottom      = 20
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	await get_tree().process_frame  # wait for panel to calculate its size
	panel.position = Vector2(
		(640 - panel.size.x)/4.0,5
	)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	# ── Title ─────────────────────────────────────────────────────────────────
	var title := Label.new()
	title.text = "CONTROLS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", COL_TITLE)
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	_add_spacer(vbox, 6)

	# ── Column headers ────────────────────────────────────────────────────────
	var header_row := _make_row()
	_add_cell(header_row, "ACTION",   COL_COLUMN_HDR)
	_add_cell(header_row, "KEYBOARD", COL_COLUMN_HDR)
	_add_cell(header_row, "GAMEPAD",  COL_COLUMN_HDR)
	vbox.add_child(header_row)

	_add_separator(vbox)
	_add_spacer(vbox, 2)

	# ── Rows ──────────────────────────────────────────────────────────────────
	for entry in CONTROLS:
		if entry[1] == null:
			_add_spacer(vbox, 6)
			var sep_label := Label.new()
			sep_label.text = entry[0]
			sep_label.add_theme_color_override("font_color", COL_HEADER)
			sep_label.add_theme_font_size_override("font_size", 11)
			vbox.add_child(sep_label)
			_add_separator(vbox)
		else:
			var row := _make_row()
			_add_cell(row, entry[0], COL_LABEL)
			_add_key_cell(row, entry[1])
			_add_key_cell(row, entry[2])
			vbox.add_child(row)
			_add_spacer(vbox, 1)

	_add_spacer(vbox, 10)

	# ── Close hint ───────────────────────────────────────────────────────────
	var hint := Label.new()
	hint.text = "Press  ESCAPE  or  Start  to close"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6, 1.0))
	hint.add_theme_font_size_override("font_size", 11)
	vbox.add_child(hint)
	
	_add_spacer(vbox, 10)

	# ── Sensitivity ──────────────────────────────────────────────────────────────
	var sens_label := Label.new()
	sens_label.text = "SENSITIVITY"
	sens_label.add_theme_color_override("font_color", COL_HEADER)
	sens_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(sens_label)

	_add_separator(vbox)
	_add_spacer(vbox, 4)

	var sens_row := HBoxContainer.new()
	sens_row.add_theme_constant_override("separation", 10)
	vbox.add_child(sens_row)

	var sens_name := Label.new()
	sens_name.text = "Sensitivity"
	sens_name.add_theme_color_override("font_color", COL_LABEL)
	sens_name.add_theme_font_size_override("font_size", 12)
	sens_name.custom_minimum_size.x = 80
	sens_row.add_child(sens_name)

	var slider := HSlider.new()
	slider.min_value = 0.1
	slider.max_value = 2.0
	slider.step = 0.1
	slider.value = PlayerSettings.sensitivity  # see note below
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sens_row.add_child(slider)

	var sens_value := Label.new()
	sens_value.text = str(snapped(slider.value, 0.1))
	sens_value.add_theme_color_override("font_color", COL_LABEL)
	sens_value.add_theme_font_size_override("font_size", 12)
	sens_value.custom_minimum_size.x = 30
	sens_row.add_child(sens_value)

	slider.value_changed.connect(func(val):
		sens_value.text = str(snapped(val, 0.1))
		PlayerSettings.sensitivity = val
	)

# ── Helpers ───────────────────────────────────────────────────────────────────

func _make_row() -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	return h

func _add_cell(parent: HBoxContainer, text: String, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.custom_minimum_size.x = 80
	parent.add_child(lbl)

func _add_key_cell(parent: HBoxContainer, text: String) -> void:
	var container := HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.custom_minimum_size.x = 100
	container.add_theme_constant_override("separation", 4)

	var parts = text.split(" / ")
	for i in parts.size():
		var part = parts[i]
		var pill := PanelContainer.new()
		var s := StyleBoxFlat.new()
		s.bg_color                   = COL_KEY
		s.corner_radius_top_left     = 5
		s.corner_radius_top_right    = 5
		s.corner_radius_bottom_left  = 5
		s.corner_radius_bottom_right = 5
		s.border_width_left          = 1
		s.border_width_right         = 1
		s.border_width_top           = 1
		s.border_width_bottom        = 1
		s.border_color               = COL_KEY_BORDER
		s.content_margin_left        = 7
		s.content_margin_right       = 7
		s.content_margin_top         = 3
		s.content_margin_bottom      = 3
		pill.add_theme_stylebox_override("panel", s)

		var lbl := Label.new()
		lbl.text = part.strip_edges()
		lbl.add_theme_color_override("font_color", COL_LABEL)
		lbl.add_theme_font_size_override("font_size", 12)
		pill.add_child(lbl)
		container.add_child(pill)

	parent.add_child(container)

func _add_separator(parent: VBoxContainer) -> void:
	var sep := ColorRect.new()
	sep.color = COL_SEPARATOR
	sep.custom_minimum_size.y = 1
	parent.add_child(sep)

func _add_spacer(parent: VBoxContainer, height: int) -> void:
	var s := Control.new()
	s.custom_minimum_size.y = height
	parent.add_child(s)
