@tool
extends Sprite2D
@export var circle_color : Color = Color(0.0, 0.0, 0.0):
	set(v):
		circle_color = v
		queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func _draw() -> void:
	draw_circle(Vector2.ZERO, 32, circle_color)
