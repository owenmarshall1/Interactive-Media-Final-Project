extends Node

var items: Array = []
var selected_index := 0

var interaction_locked := false

signal inventory_changed	

func _ready():
	#auto add gun
	set_process_unhandled_input(true)
	var gun_item = Item.new()
	gun_item.id = "gun"
	# assign the gun 3D scene
	gun_item.scene = preload("res://scenes/Game/Gun.tscn")
	add_item(gun_item)
	
	#auto add lighter
	var lighter_item = Item.new()
	lighter_item.id = "lighter"
	# assign the gun 3D scene
	lighter_item.scene = preload("res://scenes/Game/InventoryLighter.tscn")
	add_item(lighter_item)
	
	selected_index = 0
	emit_signal("inventory_changed")

func add_item(item):
	items.append(item)
	selected_index = items.size() - 1 # Select the newest item
	emit_signal("inventory_changed")

func remove_item(item):
	var i = items.find(item)
	if i != -1:
		items.remove_at(i)
		selected_index = clamp(selected_index, 0, items.size() - 1)
	emit_signal("inventory_changed")

func get_selected():
	if items.is_empty():
		return null
	selected_index = clamp(selected_index, 0, items.size() - 1)
	return items[selected_index]

func next_item():
	if items.is_empty():
		return
	selected_index = (selected_index + 1) % items.size()
	emit_signal("inventory_changed")

func prev_item():
	if items.is_empty():
		return
	selected_index = (selected_index - 1 + items.size()) % items.size()
	emit_signal("inventory_changed")
