extends Node3D

@export var HUD: CanvasLayer
@export var player: Node3D
@export var messagebox: CanvasLayer
@export var item_scene: PackedScene	

var in_contact := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and in_contact:
		messagebox.show_option("Pick up the pack of cigarettes?")
		messagebox.confirmed.connect(pickup, CONNECT_ONE_SHOT)
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		in_contact = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		in_contact = false
		
func pickup(result: bool):
	if result:
		var item = Item.new()
		item.scene = item_scene
		item.name = "Cigarettes"
		item.type = "consumable"
		item.id = "cigs"

		Inventory.add_item(item) # This will now update UI automatically
		queue_free()
	
