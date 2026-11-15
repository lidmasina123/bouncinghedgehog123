@tool
extends Control

const ART = preload("res://art/lives-speed-art.png")
const TRANSPARENCY = preload("res://menu_transparency.gdshader")
const FILLED_HEARTS = [
	Rect2(15, 55, 124, 116),
	Rect2(165, 57, 132, 122),
	Rect2(311, 50, 125, 129),
]
const EMPTY_HEARTS = [
	Rect2(20, 198, 102, 97),
	Rect2(162, 204, 110, 97),
	Rect2(306, 171, 112, 116),
]
const GLYPHS = {
	"0": Rect2(706, 130, 50, 62),
	"1": Rect2(617, 44, 35, 77),
	"2": Rect2(658, 42, 59, 76),
	"3": Rect2(718, 45, 51, 67),
	"4": Rect2(775, 37, 43, 70),
	"5": Rect2(820, 25, 48, 74),
	"6": Rect2(867, 28, 49, 67),
	"7": Rect2(899, 14, 47, 72),
	"8": Rect2(610, 137, 46, 67),
	"9": Rect2(657, 124, 42, 78),
	".": Rect2(608, 104, 14, 16),
	"x": Rect2(770, 128, 48, 58),
}

var lives = 3
var speed_text = "1.0x"

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var drawing_material = ShaderMaterial.new()
	drawing_material.shader = TRANSPARENCY
	material = drawing_material

func set_values(new_lives, multiplier):
	lives = new_lives
	if lives < 0:
		lives = 0
	if lives > 3:
		lives = 3
	speed_text = "%.1fx" % multiplier
	queue_redraw()

func _draw():
	for index in range(3):
		var source = EMPTY_HEARTS[index]
		if index < lives:
			source = FILLED_HEARTS[index]
		var scale_factor = minf(40.0 / source.size.x, 40.0 / source.size.y)
		var drawn_size = source.size * scale_factor
		var origin = Vector2(index * 46.0, 0) + (Vector2(40, 40) - drawn_size) * 0.5
		if index == 2 and index >= lives:
			for part in [Rect2(386, 171, 32, 13), Rect2(306, 184, 112, 103)]:
				draw_texture_rect_region(ART,
					Rect2(origin + (part.position - source.position) * scale_factor, part.size * scale_factor), part)
		else:
			draw_texture_rect_region(ART, Rect2(origin, drawn_size), source)

	var draw_x = 152.0
	for character in speed_text:
		var source = GLYPHS[character]
		var height = 30.0
		if character == ".":
			height = 5.0
		var scale_factor = height / source.size.y
		var origin = Vector2(draw_x, 35.0 - height)
		if character == "7":
			for part in [Rect2(899, 14, 47, 18), Rect2(915, 32, 31, 54)]:
				draw_texture_rect_region(ART,
					Rect2(origin + (part.position - source.position) * scale_factor, part.size * scale_factor), part)
		else:
			draw_texture_rect_region(ART, Rect2(origin, source.size * scale_factor), source)
		draw_x += source.size.x * scale_factor + 3.0

