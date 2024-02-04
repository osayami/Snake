class_name  FoodSpawner
extends Node

@export var walls:Walls
@export var food_scene: PackedScene
var food_position : Vector2
var food : Sprite2D
const BODY_SEGMENT_SIZE = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_food()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn_food():
	food = food_scene.instantiate()
	
	var x_pos = round(randi_range(walls.top_left_corner.x + BODY_SEGMENT_SIZE, walls.bottm_right_corner.x - BODY_SEGMENT_SIZE) / BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
	var y_pos = round(randi_range(walls.top_left_corner.y + BODY_SEGMENT_SIZE , walls.bottm_right_corner.y - BODY_SEGMENT_SIZE) / BODY_SEGMENT_SIZE) * BODY_SEGMENT_SIZE
	add_child(food)
	food_position = Vector2(x_pos , y_pos)
	food.position = food_position
	
func destroy_food():
	if food != null:
		food.queue_free()
