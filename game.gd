extends Node2D

const HillProfile = preload("res://hill_profile.gd")

var travel = 0.0
var elapsed = 0.0
var pace = 105.0
var objects = []
var next_obstacle = 510.0
var wave = 0
var obstacle_order = []
var apple_order = []
var lives = 3
var apples = 0
var hit_flash = 0.0
var running = false

@onready var character = $Hedgehog
@onready var background = $Background
@onready var object_types = [$ObjectTypes/Fox, $ObjectTypes/Stump, $ObjectTypes/Pond, $ObjectTypes/ColaCan, $ObjectTypes/Log, $ObjectTypes/GreenCan]
@onready var apple_type = $ObjectTypes/Apple
@onready var apple_types = [$ObjectTypes/Apple, $ObjectTypes/GreenApple]
@onready var game_ui = $GameUI
@onready var hud = $GameUI/LivesAndSpeed
@onready var stats_panel = $GameUI/StatsPanel
@onready var music = $Music
@onready var game_over_sound = $GameOverSound
@onready var lose_heart_sound = $LoseHeartSound
@onready var life_gain_sound = $LifeGainSound
@onready var start_screen = $StartLayer/StartScreen
@onready var start_button = $StartLayer/StartScreen/StartButton
@onready var game_over_screen = $StartLayer/GameOverScreen
@onready var final_stats = $StartLayer/GameOverScreen/Content/StatsPanel
@onready var retry_button = $StartLayer/GameOverScreen/Content/Retry

func _ready():
	var track = music.stream
	track.loop_begin = 0
	track.loop_end = int(round(track.get_length() * track.mix_rate))
	track.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.play()
	game_over_sound.stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	lose_heart_sound.stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	life_gain_sound.stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	$ObjectTypes.hide()
	game_ui.hide()
	retry_button.pressed.connect(start_run)
	start_button.pressed.connect(start_run)
	reset()
	start_button.grab_focus()

func show_game_over():
	if game_over_screen.visible:
		return
	running = false
	game_ui.hide()
	final_stats.set_values(apples, int(travel / 20.0))
	game_over_screen.show()
	music.stream_paused = true
	lose_heart_sound.stop()
	life_gain_sound.stop()
	game_over_sound.play()
	retry_button.grab_focus()

func clear_objects():
	for item in objects:
		item.hide()
		item.queue_free()
	objects.clear()

func reset():
	travel = 0.0
	elapsed = 0.0
	pace = 105.0
	character.reset_position(ground(character.start_position.x))
	clear_objects()
	next_obstacle = 510.0
	wave = 0
	obstacle_order.clear()
	apple_order.clear()
	lives = 3
	apples = 0
	hit_flash = 0.0
	game_over_sound.stop()
	lose_heart_sound.stop()
	life_gain_sound.stop()
	music.stream_paused = false
	spawn_objects()
	background.scroll_to(travel)
	character.update_look(elapsed, hit_flash)
	update_hud()

func start_run():
	game_ui.show()
	start_screen.hide()
	reset()
	game_over_screen.hide()
	running = true

func steer(direction):
	if running:
		character.steer(direction)

func _input(event):
	if running and event.is_action_pressed("ui_left"):
		steer(-1)
		get_viewport().set_input_as_handled()
	elif running and event.is_action_pressed("ui_right"):
		steer(1)
		get_viewport().set_input_as_handled()

func ground(world_x):
	var width = HillProfile.HEIGHTS.size()
	var offset = fposmod(world_x, float(width))
	var left = int(offset)
	var right = (left + 1) % width
	return $Background/Grass.position.y + lerpf(HillProfile.HEIGHTS[left], HillProfile.HEIGHTS[right], offset - float(left))

func add_object(item, world_x):
	item.world_x = world_x
	$SpawnedObjects.add_child(item)
	objects.append(item)
	place_object(item)

func place_object(item):
	item.position = Vector2(item.world_x - travel, ground(item.world_x))
	if item.is_apple:
		item.position.y -= item.height
	else:
		item.position.y += item.ground_offset

func spawn_objects():
	while next_obstacle < travel + 1120:
		if obstacle_order.is_empty():
			obstacle_order.assign(range(object_types.size()))
			obstacle_order.shuffle()
		var obstacle = object_types[obstacle_order.pop_back()].duplicate()
		add_object(obstacle, next_obstacle)
		if apple_order.is_empty():
			apple_order.assign(range(10))
			apple_order.shuffle()
		if apple_order.pop_back() < 7:
			var apple = apple_types.pick_random().duplicate()
			apple.height = [70.0, 118.0, 43.0][wave % 3] * apple.height / 70.0
			add_object(apple, next_obstacle - 138)
		next_obstacle += [340.0, 302.0, 380.0, 320.0][wave % 4]
		wave = wave + 1

func collect_apple():
	apples = apples + 1
	if apples >= 20 and lives < 3:
		apples = apples - 20
		lives = lives + 1
		life_gain_sound.play()
	update_hud()

func _physics_process(delta):
	if not running:
		return
	elapsed += delta
	pace = 105.0 + 7.0 * elapsed
	if pace > 420.0:
		pace = 420.0
	travel += pace * delta
	hit_flash = hit_flash - delta
	if hit_flash < 0:
		hit_flash = 0
	character.update_dodge(delta)
	character.bounce(delta, ground(travel + character.position.x))
	spawn_objects()
	for i in range(objects.size() - 1, -1, -1):
		var item = objects[i]
		place_object(item)
		if item.position.x < -80.0:
			objects.remove_at(i)
			item.queue_free()
			continue
		if item.is_apple:
			if character.position.distance_to(item.position) < character.apple_pickup_distance:
				objects.remove_at(i)
				item.queue_free()
				collect_apple()
		elif not item.hit and hit_flash <= 0.0:
			var box = item.hitbox()
			var closest = character.position.clamp(box.position, box.end)
			if character.position.distance_to(closest) < character.collision_radius:
				item.mark_hit()
				lives = lives - 1
				hit_flash = 0.65
				if lives == 0:
					show_game_over()
					break
				lose_heart_sound.play()
	background.scroll_to(travel)
	character.update_look(elapsed, hit_flash)
	update_hud()

func update_hud():
	hud.set_values(lives, pace / 105.0)
	stats_panel.set_values(apples, int(travel / 20.0))
