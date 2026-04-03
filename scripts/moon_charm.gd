extends Node3D

@export var player: Node3D
@export var HUD: CanvasLayer

# --- Unique per charm ---
@export var charm_id: String   # "full", "crescent", "gibbous"
@export var item_scene: PackedScene

var in_contact = false

func _process(_delta):
	if Input.is_action_just_pressed("interact") and in_contact:
		HUD.messagebox.show_option("Pick up the moon charm?")
		HUD.messagebox.confirmed.connect(_on_pickup, CONNECT_ONE_SHOT)

func _on_pickup(result: bool):
	if result:
		var item = Item.new()
		item.id = charm_id
		item.type = "moon_charm"
		item.scene = item_scene

		Inventory.add_item(item)
		queue_free()

func _on_area_3d_body_entered(body):
	if body == player:
		in_contact = true

func _on_area_3d_body_exited(body):
	if body == player:
		in_contact = false
