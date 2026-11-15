extends Area2D

@export var ground_offset = 0.0
var world_x = 0.0
var hit = false
var is_apple = false

func hitbox():
	var shape_node = $CollisionShape2D
	var box = Rect2(-shape_node.shape.size * 0.5, shape_node.shape.size)
	return shape_node.global_transform * box

func mark_hit():
	hit = true
	modulate.a = 0.45
