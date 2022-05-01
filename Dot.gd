extends Node2D
tool

func _ready():
	update()

func _draw():
	draw_circle(Vector2(0, 0), 2.0, Color.red)
