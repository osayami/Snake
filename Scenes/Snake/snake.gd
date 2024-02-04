class_name Snake
extends Node2D

@onready var snake_parts: Node = $SnakeParts
@onready var timer: Timer = $Timer

@export var walls:Walls

signal on_game_over
signal on_point_scored(points:int)
var points = 0

enum CollisionDirection{
	TOP,
	BOTTOM , 
	RIGHT ,
	LEFT
}
const BODY_SEGMENT_SIZE = 32

var body_parts = []
var body_texture = preload("res://Assets/Snake.png")
var move_direction = Vector2.ZERO
var walls_dict = {}
var food_spawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var head = Sprite2D.new()
	head.position = Vector2.ZERO
	head.scale = Vector2.ONE
	head.texture = body_texture
	snake_parts.add_child(head)
	body_parts.append(head)
	walls_dict = walls.walls_dict
	food_spawner = get_tree().get_first_node_in_group("food_spawner") as FoodSpawner
	timer.timeout.connect(on_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right") and move_direction.x != -1:
		move_direction = Vector2.RIGHT
		
	elif event.is_action_pressed("left") and move_direction.x != 1:
		move_direction = Vector2.LEFT
		
	elif event.is_action_pressed("up") and move_direction.y != 1:
		move_direction = Vector2.UP
	
	elif event.is_action_pressed("down") and move_direction.y != -1:
		move_direction = Vector2.DOWN
		
	#print_debug(move_direction)

func on_timeout():
	#wall collision
	var new_head_position = position + move_direction * BODY_SEGMENT_SIZE
	var wall_collison = check_wall_collision(new_head_position)
	if wall_collison == null:
		move_to_position(new_head_position)
	else:
		var position_after_wall_collision = get_position_after_wall_collision(wall_collison,new_head_position)
		new_head_position = position_after_wall_collision
		move_to_position(position_after_wall_collision)
	
	# Food collision
	if new_head_position == food_spawner.food_position:
		food_spawner.destroy_food()
		food_spawner.spawn_food()
		add_body_part()
		points += 1
		on_point_scored.emit(points)
		
	# snake collisions
	var snake_collisions = check_snake_collision(new_head_position)
	if snake_collisions:
		timer.stop()
		on_game_over.emit()
	
func move_to_position(new_position):
	
	if body_parts.size() > 1:
		var last_element = body_parts.pop_back()
		last_element.position = body_parts[0].position
		body_parts.insert(1 , last_element)
		
	position = new_position
	body_parts[0].position = position

func check_wall_collision(new_head_position:Vector2):
	if new_head_position.x == walls_dict["left"].position.x and move_direction == Vector2.LEFT:
		return CollisionDirection.LEFT
	elif new_head_position.x == walls_dict["right"].position.x  and move_direction == Vector2.RIGHT:
		return CollisionDirection.RIGHT
	elif new_head_position.y == walls_dict["top"].position.y and move_direction == Vector2.UP:
		return CollisionDirection.TOP
	elif new_head_position.y == walls_dict["bottom"].position.y  and move_direction == Vector2.DOWN:
		return CollisionDirection.BOTTOM


func get_position_after_wall_collision(wall_collison : CollisionDirection,new_head_position:Vector2):
	if (wall_collison == CollisionDirection.LEFT or wall_collison == CollisionDirection.RIGHT) and new_head_position.y <= 0:
		move_direction = Vector2.DOWN
	elif (wall_collison == CollisionDirection.LEFT or wall_collison == CollisionDirection.RIGHT) and new_head_position.y > 0:
		move_direction = Vector2.UP
	elif (wall_collison == CollisionDirection.TOP or wall_collison == CollisionDirection.BOTTOM) and new_head_position.x <= 0:
		move_direction = Vector2.RIGHT
	elif (wall_collison == CollisionDirection.TOP or wall_collison == CollisionDirection.BOTTOM) and new_head_position.x > 0:
		move_direction = Vector2.LEFT
		
	return body_parts[0].position + move_direction * BODY_SEGMENT_SIZE
	

func add_body_part():
	var new_part = Sprite2D.new()
	new_part.texture = body_texture
	new_part.scale = Vector2(.9,.9)
	snake_parts.add_child(new_part)
	new_part.position = body_parts[-1].position - move_direction * BODY_SEGMENT_SIZE
	body_parts.append(new_part)

func check_snake_collision(new_head_position):
	var body_parts_without_head =  body_parts.slice(1,body_parts.size())
	if body_parts_without_head.filter(func (part): return part.position == position):
		return true
	return false
