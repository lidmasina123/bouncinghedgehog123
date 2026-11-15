extends Node2D

@export var   sky_speed = 0.12
@export var     trees_speed = 0.45

func scroll_to(distance):
	scroll_layer($Sky, distance * sky_speed)
	
	scroll_layer ($Trees, distance * trees_speed)
	 
	
	scroll_layer($Grass, distance)

func scroll_layer(layer, distance):
	var first = layer.get_node("First")
	var second = layer.get_node("Second")
	

	var width = first.texture.get_width() * first.scale.x
	var offset = fposmod(distance, width)
	first.position.x = -offset
	
	second.position.x = width - offset
