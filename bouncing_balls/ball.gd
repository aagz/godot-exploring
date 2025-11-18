extends RigidBody2D

@export var radius := 16
@export var color := Color(0.3, 0.7, 1.0)
@export var gravity := 0

func _ready():
	$CollisionShape2D.shape.radius = radius
	gravity_scale = gravity

	linear_velocity = Vector2(
		randf_range(-200, 200),
		randf_range(-200, 200)
	)
	
	var mat = PhysicsMaterial.new()
	mat.bounce = 1
	mat.friction = 0.1
	mat.absorbent = false
	self.physics_material_override = mat

func _draw():
	draw_circle(Vector2.ZERO, radius, color)

func _process(delta):
	#update()
	pass
