extends Node3D

@export var player: Node3D
@export var HUD: CanvasLayer
@export var enemy_scene: PackedScene

# --- Unique per charm ---
@export var charm_id: String   # "full", "crescent", "gibbous"
@export var item_scene: PackedScene

var in_contact = false

var enemy_spawn_points: Array[Node3D] = []
func _ready() -> void:
	enemy_spawn_points= [
		$"../../Altars/Altar_fake/EnemySpawn1",
		$"../../Altars/Altar_fake/EnemySpawn2",
		$"../../Altars/Altar_fake/EnemySpawn3"
	]
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
		if item.id == "gibbous":
			for point in enemy_spawn_points:
				var enemy = enemy_scene.instantiate()
				get_parent().add_child(enemy)
				enemy.global_position = point.global_position
				enemy.player = $"../../../Player"
			
		queue_free()

func _on_area_3d_body_entered(body):
	if body == player:
		in_contact = true

func _on_area_3d_body_exited(body):
	if body == player:
		in_contact = false
