extends Control

@onready var prev_view = $HBoxContainer/Prev/SubViewport
@onready var current_view = $HBoxContainer/Current/SubViewport
@onready var next_view = $HBoxContainer/Next/SubViewport

var items: Array = []
var selected_index := 0

func _ready():
	Inventory.inventory_changed.connect(update_ui)
	update_ui()
	set_process(true)

# -------------------------
# Update the SubViewport UI
# -------------------------
func update_ui():
	items = Inventory.items
	selected_index = Inventory.selected_index if Inventory.items.size() > 0 else 0

	if items.is_empty():
		clear_view(prev_view)
		clear_view(current_view)
		clear_view(next_view)
		return

	# Current
	show_item(current_view, items[selected_index])

	# Prev
	if items.size() > 1:
		var prev_i = (selected_index - 1 + items.size()) % items.size()
		show_item(prev_view, items[prev_i])
	else:
		clear_view(prev_view)

	# Next
	if items.size() > 1:
		var next_i = (selected_index + 1) % items.size()
		show_item(next_view, items[next_i])
	else:
		clear_view(next_view)
# -------------------------
# Helpers to instantiate models
# -------------------------
func clear_view(view):
	var root = view.get_child(0)
	for child in root.get_children():
		if not (child is Camera3D or child is DirectionalLight3D):
			child.free()

func show_item(view, item):
	if item == null:
		clear_view(view)
		return
	var root = view.get_child(0)  # Node3D inside SubViewport
	clear_view(view)              # ← uncomment/move this BEFORE adding
	var instance = item.scene.instantiate()
	root.add_child(instance)
