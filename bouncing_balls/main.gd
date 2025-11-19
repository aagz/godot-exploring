extends Node2D

#@export var ball_scene: PackedScene
var ball_scene = preload("res://ball.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(100):
		var ball = ball_scene.instantiate()
		
		ball.position = Vector2(
			randf_range(50, 1230),
			randf_range(50, 670)
		)
		
		ball.color = Color(randf(), randf(), randf())
		
		# случайная скорость
		var speed = randf_range(150, 1000)  # диапазон скорости
		var angle = randf() * TAU        # угол направления 0..360°
		ball.linear_velocity = Vector2(cos(angle), sin(angle)) * speed
		
		# случайная масса
		ball.mass = randf_range(0.5, 3.0)
		
		add_child(ball)
		
	var player_ball = ball_scene.instantiate()
	player_ball.position = Vector2(640, 360)
	player_ball.is_player = true
	#player_ball.set_mass = 10
	#player_ball.radius = 20
	add_child(player_ball)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
