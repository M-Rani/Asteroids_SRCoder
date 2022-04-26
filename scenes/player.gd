extends Area2D

var velocity = Vector2.ZERO
var screen_size = OS.get_window_size()
var escape_size = 15
var is_alive = true
var is_invincible = true

export(bool) var use_game_over_timer = true
export(float) var game_over_timer = 5

export(int) var rotation_speed = 5
export(float) var thrust_strength = 10
var thrust = 0

# Custom Signal
signal player_destroyed

func _ready():
	# Spawn player pointing up
	rotation = -1.579
	# Spawn Player at the center of the Screen
	position = screen_size/2
	visible = true
	$sfx/shield_up.play()
	# Set up deathtimer
	$game_over_timer.wait_time = game_over_timer

func _process(delta):
	# Get Input and rotate player
	var rot = Input.get_axis("Left", "Right") * rotation_speed
	rotate(rot * delta)

	# Move with thrust if alive
	if is_alive:
		thrust = Input.get_action_strength("Thrust")
	else:
		thrust = 0
		visible = false

	# Thruster sound and sprite
	if thrust && $sfx/thruster_sound.is_playing() == false && is_alive:
		$thruster_sprite.visible = true
		$sfx/thruster_sound.play()
	elif not thrust && is_alive:
		$thruster_sprite.visible = false
		$sfx/thruster_sound.stop()
	elif not is_alive:
		$sfx/thruster_sound.stop()

	# Show shield
	if is_invincible: $shield.visible = true
	else: $shield.visible = false

	# If dead, press fire to go back to menu faster
	if not is_alive and Input.is_action_just_pressed("Fire"):
		get_tree().change_scene("res://scenes/menu.tscn")

	velocity += transform.x * thrust * thrust_strength
	velocity = lerp(velocity, Vector2.ZERO, 1 * delta)
	position += velocity * delta

	wrap()

func wrap():
	screen_size = OS.get_window_size()

	# Wraparound left and right
	if position.x < -escape_size:
		position.x = screen_size.x + escape_size
	elif position.x > screen_size.x + escape_size:
		position.x = -escape_size

	# Wraparound top and bottom
	if position.y < -escape_size:
		position.y = screen_size.y + escape_size
	elif position.y > screen_size.y + escape_size:
		position.y = -escape_size

func reset_invincibility():
	is_invincible = true
	$sfx/shield_up.play()
	$invincibilty_timer.start()

func _on_player_area_entered(area):
	if area is Asteroid && not is_invincible || area is Rock && not is_invincible:
		# Kill player
		is_alive = false

		# Play Sound Start
		$sfx/ship_explosion_sound.play()
		emit_signal("player_destroyed")

		# If game over timer is to be used...
		if use_game_over_timer:
			$game_over_timer.start()

	elif area is Asteroid || area is Rock:
		$sfx/shield_sound.play()

func _on_game_over_timer_timeout() -> void:
	# When timer hits 0, put player back at menu
	get_tree().change_scene("res://scenes/menu.tscn")

func _on_invincibilty_timer_timeout() -> void:
	$sfx/shield_down.play()
	# Player is vulnerable when timer hits 0
	is_invincible = false
