extends Node

# Game script spawn in a number of asteroids at astart
export (int) var num_asteroids = 1
export (int) var larger_asteroid_pts = 10
export (int) var medium_rock_pts = 5
onready var asteroid = preload("res://scenes/asteroid.tscn")
onready var bullet = preload("res://scenes/bullet.tscn")
onready var rock = preload("res://scenes/rock.tscn")
var num_asteroids_left = 0
var score = 0

func _ready():
	spawn_wave()

func get_random_position():
	randomize()
	# return a random screen position
	var v = Vector2(rand_range(0,OS.get_window_size().x),rand_range(0,OS.get_window_size().y))
	return v

func _process(delta):
	# Check for key and shoot bullet
	if Input.is_action_just_pressed("Fire") && $player.is_alive:
		# Shoot the bullet
		var new_bullet = bullet.instance()
		new_bullet.position = $player.position
		new_bullet.rotation = $player.rotation
		add_child(new_bullet)
		$laser_sound.play()

func update_score_text():
	if score >= 9999:
		$canvas_layer.shake(10)
		$canvas_layer/score_label.text = "Score: 9999"
	else:
		if score % 100 == 0:
			$canvas_layer.shake(5)
		else:
			$canvas_layer.shake()
		$canvas_layer/score_label.text = "Score: " + str(score).pad_zeros(4)

func spawn_wave():
	$player.reset_invincibility()
	num_asteroids += [1,2][randi() % 2]
	# Spawn a number of asteroids
	for n in num_asteroids:
		var new_asteroid = asteroid.instance()
		new_asteroid.position = get_random_position()
		new_asteroid.connect("asteroid_destroyed",self,"_on_asteroid_destroyed")
		add_child(new_asteroid)
		num_asteroids_left += 1

func _on_asteroid_destroyed(pos) -> void:
	$large_explosion_sound.play()
	$camera.shake()
	score += larger_asteroid_pts
	num_asteroids_left -= 1

	# Spawn rocks on Asteroid death
	for i in range([3,4][randi() % 2]):
		var new_rock = rock.instance()
		new_rock.position = pos
		add_child(new_rock)
		new_rock.connect("rock_destroyed",self,"_on_rock_destroyed")
		num_asteroids_left += 1

	# update the current score
	update_score_text()



func _on_rock_destroyed():
	# add to score and shake
	$medium_explosion_sound.play()
	$camera.shake()
	score += medium_rock_pts
	num_asteroids_left -= 1

	# update the current score
	update_score_text()

	if num_asteroids_left <= 0:
		$camera.shake(2)
		spawn_wave()

func _on_player_player_destroyed() -> void:
	$camera.shake()
