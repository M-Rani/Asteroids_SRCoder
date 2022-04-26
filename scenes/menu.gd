extends Node2D

var t = 0
var frequency = 50
var magnitude = 1
var x_start = 0
var y_start = 0
var shook = 0

export (float) var strength = 0.15
export (int) var num_asteroids = 5
onready var play_btn_pos = $CanvasLayer/Panel/play.rect_position
onready var screen_size = OS.get_window_size()
onready var asteroid = preload("res://scenes/asteroid.tscn")

func shake(shake_strength:float = 1.0):
	randomize()
	x_start = rand_range(0,2*PI)
	y_start = rand_range(0,2*PI)
	magnitude = [-25,25][randi() % 2] * shake_strength

func get_random_position():
	randomize()
	# return a random screen position
	var v = Vector2(rand_range(0,OS.get_window_size().x),rand_range(0,OS.get_window_size().y))
	return v

func _ready():
	shake()
	print("start")

# 	Spawn a number of asteroids
	for n in num_asteroids:
		var new_asteroid = asteroid.instance()
		new_asteroid.position = get_random_position()
		$CanvasLayer/asteroid_field.add_child(new_asteroid)

func _process(delta):
	# Readjust play button to window size
#	screen_size = OS.get_window_size()
#	play_btn_pos = screen_size / 2

	# Trigger event if mouse hover over button
	if $CanvasLayer/Panel/play.is_hovered():
		if shook != 1:
			shake()
			$sfx/button_sound.play()
			shook = 1
	else:
		shook = 0

	# Shake
	t += delta
	magnitude =  lerp(magnitude, 0, delta * 15)
	$CanvasLayer.offset.x = sin(t*frequency+x_start) * magnitude * strength
	$CanvasLayer.offset.y = sin(t*frequency+y_start) * magnitude * strength
	$CanvasLayer/Panel/play.set_position(Vector2(play_btn_pos.x + [-magnitude,magnitude][randi() % 2] * strength, play_btn_pos.y + [-magnitude,magnitude][randi() % 2] * strength))

func _on_play_button_down() -> void:
	shake()
	$sfx/button_d_sound.play()
	$play_timer.start()


func _on_play_timer_timeout() -> void:
	get_tree().change_scene("res://scenes/game.tscn")
