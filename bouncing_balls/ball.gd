extends RigidBody2D

@export var radius := 5
@export var color := Color(0.3, 0.7, 1.0)
@export var gravity := 1
@export var is_player := false
@export var set_mass := 1

func _ready():
	$CollisionShape2D.shape.radius = radius
	gravity_scale = gravity
	mass = set_mass

	linear_velocity = Vector2(
		randf_range(-200, 200),
		randf_range(-200, 200)
	)
	
	var mat = PhysicsMaterial.new()
	mat.bounce = 0.5
	mat.friction = 1
	mat.absorbent = false
	self.physics_material_override = mat
	
func _physics_process(delta: float) -> void:
	if is_player:
		var dir = (get_global_mouse_position() - global_position)
		linear_velocity = dir * 5

func _draw():
	draw_circle(Vector2.ZERO, radius, color)

func _process(delta):
	#update()
	pass
