extends CharacterBody2D

# Цвет боида. Используем randf(), чтобы при создании случайно выбрать цвет
@export var boid_color : Color = Color(randf(), randf(), randf())

# Максимальная скорость боида
@export var max_speed := 200.0

# Минимальная скорость боида (чтобы он не "залипал")
@export var min_speed := 100.0

# Метод, вызываемый при старте сцены
func _ready() -> void:
	# Устанавливаем цвет для визуального представления боида (Polygon2D)
	$Polygon2D.color = boid_color
	
	# Инициализация скорости боида в случайном направлении
	# Vector2.RIGHT — вектор вправо, rotated(randf() * TAU) поворачивает на случайный угол
	# TAU = 2π, то есть полный круг
	velocity = Vector2.RIGHT.rotated(randf() * TAU) * max_speed
	

# Метод, который вызывается из Main.gd для обновления позиции боида
# accel — вычисленное ускорение (соседи + избегание)
# delta — время кадра для корректного перемещения
func update_boid(accel: Vector2, delta: float) -> void:
	# Добавляем ускорение к текущей скорости
	velocity += accel * delta
	
	# Ограничиваем скорость: если слишком быстрая — нормализуем до max_speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	# Если слишком медленная — поднимаем до min_speed
	elif velocity.length() < min_speed:
		velocity = velocity.normalized() * min_speed
		
	# Поворачиваем боид в направлении движения
	# +PI/2, потому что Polygon2D обычно смотрит вверх, а вектор 0° — вправо
	rotation = velocity.angle() + PI/2

	# Обновляем позицию боида
	# delta используется для корректного перемещения относительно времени кадра
	position += velocity * delta
