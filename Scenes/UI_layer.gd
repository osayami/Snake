extends CanvasLayer

@onready var button_container: HBoxContainer = $BoxContainer
@onready var restart: Button = %Restart
@onready var quit: Button = %Quit

@onready var gameover_label: Label = $GameoverLabel
@onready var points_label: Label = $PointsLabel

@onready var snake: Snake = $"../Snake"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	snake.on_game_over.connect(on_game_over)
	snake.on_point_scored.connect(on_point_scored)

func on_game_over():
	button_container.visible = true
	gameover_label.visible = true
	
func on_point_scored(points: int):
	points_label.text = "Points: %d" % points   

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().exit()
