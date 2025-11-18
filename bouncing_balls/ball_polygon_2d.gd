extends Polygon2D


@export var radius: float = 16
@export var segments: int = 32
@export var color_circle: Color = Color.RED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color = color_circle
	var points: Array[Vector2] = []
	for i in range(segments):
		var angle = i * TAU / segments
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	polygon = points


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
