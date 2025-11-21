extends CharacterBody2D

@export var speed := 400
@export var turn_speed := 3.0

var current_velocity := Vector2.ZERO

func _physics_process(delta):
	# Поворот игрока
	if Input.is_action_pressed("ui_left"):
		rotation -= turn_speed * delta
	if Input.is_action_pressed("ui_right"):
		rotation += turn_speed * delta

	# Движение вперед по носу
	var dir = Vector2.UP.rotated(rotation)
	current_velocity = dir * speed if Input.is_action_pressed("ui_up") else Vector2.ZERO

	# Двигаем игрока с проверкой столкновений
	var collision = move_and_collide(current_velocity * delta)
	if collision:
		var normal = collision.get_normal()
		# Отражаем скорость по нормали
		current_velocity = current_velocity - 2 * current_velocity.dot(normal) * normal
