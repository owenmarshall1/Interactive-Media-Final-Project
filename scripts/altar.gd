extends Node3D

@export var player: Node3D
@export var HUD: CanvasLayer
@export var correct_charm: String
@export var charm_position: Node3D
@export var map: Node3D
@export var altar_id: String

var in_contact = false
var can_interact = true 
var current_charm: Item = null
var current_charm_instance: Node3D = null

func _unhandled_input(_event):
	if not in_contact or not can_interact:
		return

	if Input.is_action_just_pressed("interact"):
		can_interact = false
		if current_charm:
			HUD.messagebox.show_option("There is a " + current_charm.id + " moon charm here.\nDo you want to take it back?")
			HUD.messagebox.confirmed.connect(retrieve_charm, CONNECT_ONE_SHOT)
		else:
			HUD.messagebox.show_message("It looks like I could fit something in the hole.")
			await_message_close()

	elif Input.is_action_just_pressed("use"):
		can_interact = false
		Inventory.interaction_locked = true

		var selected_item = Inventory.get_selected()
		if selected_item == null:
			Inventory.interaction_locked = false
			can_interact = true
			return
		if selected_item.type != "moon_charm":
			HUD.messagebox.show_message("This doesn't fit.")
			await_message_close()
		elif current_charm:
			HUD.messagebox.show_option("There is a " + current_charm.id + " moon charm here.\nDo you want to take it back and replace it?")
			HUD.messagebox.confirmed.connect(swap_charm, CONNECT_ONE_SHOT)
		else: 
			HUD.messagebox.show_option("It appears to fit.\nPlace the " + selected_item.id + " moon charm in the slot?")
			HUD.messagebox.confirmed.connect(place_charm, CONNECT_ONE_SHOT)
		


func swap_charm(result: bool):
	if result:
		var item_to_place = Inventory.get_selected()
		
		if current_charm:
			if current_charm.id == correct_charm:
				map.correct_charm_count -= 1
				print("correct count: " + str(map.correct_charm_count))
			Inventory.add_item(current_charm)
			if current_charm_instance:
				current_charm_instance.queue_free()
				current_charm_instance = null
			current_charm = null

		place_charm_item(item_to_place)
	else:
		can_interact = true
		Inventory.interaction_locked = false

func place_charm_item(item: Item):
	if item == null:
		can_interact = true
		Inventory.interaction_locked = false
		return
		
	Inventory.remove_item(item)
	current_charm = item
	if current_charm_instance:
		current_charm_instance.queue_free()
		
	current_charm_instance = current_charm.scene.instantiate()
	charm_position.add_child(current_charm_instance)
	current_charm_instance.transform = Transform3D()
	
	if current_charm.id == correct_charm:
		map.correct_charm_count +=1
		print("It fits perfectly! " + str(map.correct_charm_count))
	else:
		print("It fits, but it doesn't seem correct.")
		
	await_message_close()
	
func place_charm(result: bool):
	if not result:
		can_interact = true
		Inventory.interaction_locked = false
		return
	place_charm_item(Inventory.get_selected())


func retrieve_charm(result: bool):
	if result and current_charm:
		if current_charm.id == correct_charm:
			map.correct_charm_count -= 1
			print("correct count: " + str(map.correct_charm_count))
		Inventory.add_item(current_charm)
		current_charm = null
		if current_charm_instance:
			current_charm_instance.queue_free()
			current_charm_instance = null
	await_message_close()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		in_contact = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		in_contact = false


func await_message_close() -> void:
	while HUD.messagebox.is_showing:
		await get_tree().process_frame
	Inventory.interaction_locked = false
	can_interact = true
