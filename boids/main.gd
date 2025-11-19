extends Node2D

# Сцена одного боида, которую мы будем инстанцировать
@export var boid_scene: PackedScene

# Количество боидов, которые нужно создать
@export var boid_count := 100

# Радиус, в котором боид "видит" соседей и учитывает их при движении
@export var neighbour_radius := 200.0

# Минимальная дистанция, на которой боид начинает активно избегать столкновения
@export var avoid_dist := 100.0

# Список для хранения всех боидов, чтобы можно было легко проходить по ним каждый кадр
var boids := []

# Метод, вызываемый при старте сцены
func _ready() -> void:
	for i in range(boid_count):
		# Создаём экземпляр боида из сцены
		var b = boid_scene.instantiate()
		
		# Ставим боида в случайную позицию на экране
		# randi_range(a,b) возвращает случайное целое число между a и b
		b.position = Vector2(randi_range(100,1820), randi_range(100,980))
		
		# Добавляем боида в сцену, чтобы он отображался и обновлялся
		add_child(b)
		
		# Назначаем случайный цвет боиду
		b.boid_color = Color(randf(), randf(), randf())
		
		# Добавляем боида в список для дальнейшего вычисления поведения
		boids.append(b)
		

# Метод, вызываемый каждый кадр
# delta — время прошедшее с предыдущего кадра (нужно для корректного движения)
func _process(delta: float) -> void:
	for b in boids:
		# Вычисляем ускорение для каждого боида на этом кадре
		var accel = compute_boid_accel(b)
		
		# Передаём ускорение боиду, чтобы он обновил своё движение
		b.update_boid(accel, delta)
		

# Вычисление ускорения для одного боида
func compute_boid_accel(b):
	# Инициализация векторов для разных компонентов поведения
	var center := Vector2.ZERO  # для центра соседей (cohesion)
	var avoid := Vector2.ZERO   # для избежания столкновений (separation)
	var align := Vector2.ZERO   # для выравнивания направления (alignment)
	var count := 0              # количество соседей в радиусе видимости

	# Проходим по всем боидам
	for other in boids:
		if other == b:
			continue  # не учитываем самого себя
		var dist = b.position.distance_to(other.position)  # расстояние до другого боида
		
		# Если сосед в радиусе видимости
		if dist < neighbour_radius:
			center += other.position    # суммируем позиции для вычисления центра
			align += other.velocity     # суммируем скорости для выравнивания направления
			count += 1                  # увеличиваем счётчик соседей
			
			# Если сосед слишком близко — добавляем вектор отталкивания
			if dist < avoid_dist:
				# Чем ближе сосед, тем сильнее сила отталкивания
				avoid -= (other.position - b.position).normalized() * (avoid_dist - dist)/avoid_dist

	# Если есть соседи
	if count > 0:
		# Средняя позиция соседей — центр для cohesion
		center /= count
		# Средняя скорость соседей — для alignment
		align /= count
		
	var accel := Vector2.ZERO  # итоговое ускорение

	if count > 0:
		# Добавляем к ускорению компонент движения к центру соседей
		accel += (center - b.position).normalized() * 20
		
		# Добавляем компонент выравнивания скорости
		accel += (align.normalized() - b.velocity.normalized()) * 30
		
		# Добавляем компонент отталкивания для separation
		accel += avoid * 60
		
	# Добавляем ускорение для избегания стен
	accel += avoid_walls(b)
	
	# Возвращаем итоговое ускорение
	return accel 
	

# Вычисление ускорения, чтобы боид не улетел за пределы экрана
func avoid_walls(b):
	var a := Vector2.ZERO   # вектор ускорения для отталкивания от стен
	var screen := get_viewport_rect()  # размеры экрана
	
	var margin := 100  # отступ от краёв, когда включается отталкивание
	var push := 200    # сила ускорения от стен

	# Проверка левой и правой стенки
	if b.position.x < margin:
		a += Vector2.RIGHT * push  # толкаем вправо
	elif b.position.x > screen.size.x - margin:
		a += Vector2.LEFT * push   # толкаем влево

	# Проверка верхней и нижней стенки
	if b.position.y < margin:
		a += Vector2.DOWN * push   # толкаем вниз
	elif b.position.y > screen.size.y - margin:
		a += Vector2.UP * push     # толкаем вверх

	# Возвращаем вектор ускорения, чтобы использовать в compute_boid_accel
	return a
