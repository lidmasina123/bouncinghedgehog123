@tool
extends Control

const DIGIT_ART = preload("res://art/stats-art.png")
const PANEL_ART = preload("res://art/stats-panel.png")
const TRANSPARENCY = preload("res://menu_transparency.gdshader")
const PANEL = Rect2(48, 19, 592, 319)
const DIGITS = [
	Rect2(191, 133, 58, 67),
	Rect2(87, 50, 43, 58),
	Rect2(141, 46, 43, 60),
	Rect2(187, 44, 43, 65),
	Rect2(231, 40, 58, 59),
	Rect2(292, 33, 50, 63),
	Rect2(348, 30, 44, 61),
	Rect2(391, 30, 45, 64),
	Rect2(80, 124, 61, 77),
	Rect2(142, 128, 42, 72),
]
const APPLE_VALUE = Rect2(322, 131, 176, 56)
const DISTANCE_VALUE = Rect2(366, 191, 118, 56)

var apple_count = 0
var meters = 0

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var drawing_material = ShaderMaterial.new()
	drawing_material.shader = TRANSPARENCY
	material = drawing_material
	resized.connect(queue_redraw)
	queue_redraw()

func set_values(new_apples, new_meters):
	apple_count = new_apples
	meters = new_meters
	if apple_count < 0:
		apple_count = 0
	if meters < 0:
		meters = 0
	queue_redraw()

func draw_number(value, box):
	var text = str(value)
	var width = 0.0
	var gap = 3.0
	for character in text:
		var source = DIGITS[int(character)]
		width += source.size.x / source.size.y * box.size.y
	width += gap * (text.length() - 1)
	var scale_factor = minf(1.0, box.size.x / width)
	var draw_x = box.position.x + (box.size.x - width * scale_factor) * 0.5
	var height = box.size.y * scale_factor
	var top = box.position.y + (box.size.y - height) * 0.5
	for character in text:
		var source = DIGITS[int(character)]
		var digit_width = source.size.x / source.size.y * height
		draw_texture_rect_region(DIGIT_ART, Rect2(draw_x, top, digit_width, height), source)
		draw_x += digit_width + gap * scale_factor

func _draw():
	var scale_factor = minf(size.x / PANEL.size.x, size.y / PANEL.size.y)
	var origin = (size - PANEL.size * scale_factor) * 0.5
	draw_set_transform(origin, 0.0, Vector2(scale_factor, scale_factor))
	draw_texture_rect_region(PANEL_ART, Rect2(Vector2.ZERO, PANEL.size), PANEL)
	draw_number(apple_count, APPLE_VALUE)
	draw_number(meters, DISTANCE_VALUE)
	draw_set_transform(Vector2.ZERO)

