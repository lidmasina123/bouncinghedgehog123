extends Node2D

@export var jump_strength = 370.0
@export var gravity = 525.0
@export var dodge_distance = 48.0
@export_range(0.01, 1.0) var dodge_time = 0.18
@export var left_limit = 72.0
@export var right_limit = 430.0
@export var collision_radius = 24.0
@export var apple_pickup_distance = 34.0
@export var sway_amount = 0.1
@export var roll_amount = 0.56

var vertical_speed = -370.0
var dodge_age = 0.18
var dodge_start = 160.0
var dodge_goal = 160.0
var dodge_direction = 0
var pending = []
var start_position = Vector2.ZERO

func _ready():
	start_position = position

func reset_position(floor_y):
	position = start_position
	position.y = floor_y - collision_radius
	vertical_speed = -jump_strength
	dodge_age = dodge_time
	dodge_direction = 0
	dodge_start = position.x
	dodge_goal = position.x
	pending.clear()
	rotation = 0
	modulate = Color.WHITE

func steer(direction):
	if pending.size() < 12:
		pending.append(direction)

func update_dodge(delta):
	if dodge_age >= dodge_time and not pending.is_empty():
		dodge_direction = pending.pop_front()
		dodge_start = position.x
		dodge_goal = position.x + dodge_distance * dodge_direction
		if dodge_goal < left_limit:
			dodge_goal = left_limit
		if dodge_goal > right_limit:
			dodge_goal = right_limit
		dodge_age = 0.0
	dodge_age = dodge_age + delta
	if dodge_age > dodge_time:
		dodge_age = dodge_time
	if dodge_direction != 0:
		var progress = dodge_age / dodge_time
		position.x = lerpf(dodge_start, dodge_goal, 1.0 - (1.0 - progress) ** 2)

func bounce(delta, floor_y):
	vertical_speed += gravity * delta
	position.y += vertical_speed * delta
	if position.y >= floor_y - collision_radius and vertical_speed >= 0:
		position.y = floor_y - collision_radius
		vertical_speed = -jump_strength

func update_look(elapsed, hit_flash):
	var sway = sin(elapsed * 4.0) * sway_amount
	var dodge_roll = 0.0
	if dodge_age < dodge_time:
		dodge_roll = sin(PI * dodge_age / dodge_time)
	rotation = sway + dodge_direction * dodge_roll * roll_amount
	modulate = Color.WHITE
	if hit_flash > 0 and int(hit_flash * 18) % 2 == 1:
		modulate = Color(1, 1, 1, 0.55)
