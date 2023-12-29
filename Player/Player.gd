extends Area2D

var is_alive = true # Flag to check if the player is alive


# Constants
const TILE_SIZE = 64 # Change this to your tile size
const DASH_SPEED = 400 # Speed of the dash, adjust as needed

# Variables
var target_position: Vector2
var is_dashing: bool = false

# References
@onready var animated_sprite = $AnimatedSprite2D

var start_pos: Vector2
var spawn_pos: Vector2

# Variables for handling hurt movement
var hurt_movement_active: bool = false
var hurt_target_position: Vector2

var sliding: bool = false #ice slide

func _ready():
	spawn_pos = global_position
	#reset()


func _process(delta):
	if is_alive:
		if is_dashing:
			dash_towards_target(delta)
		elif hurt_movement_active:
			move_back_on_hurt(delta)
		else:
			handle_input()

func handle_input():
	var direction = Vector2.ZERO
	if Input.is_action_just_pressed("ui_right"):
		direction.x += 1
	elif Input.is_action_just_pressed("ui_left"):
		direction.x -= 1
	elif Input.is_action_just_pressed("ui_down"):
		direction.y += 1
	elif Input.is_action_just_pressed("ui_up"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		start_dash(direction)
		Tick.run_tick(1)

func start_dash(direction: Vector2):
	start_pos = global_position
	target_position = global_position + direction * TILE_SIZE
	is_dashing = true
	if !sliding:
		animated_sprite.play("Run")
	else:
		animated_sprite.play("Idle")
		
	animated_sprite.flip_h = direction.x < 0

func dash_towards_target(delta):
	var direction = (target_position - global_position).normalized()
	global_position += direction * DASH_SPEED * delta
		
	if global_position.distance_to(target_position) < 4:
		finish_dash(direction)

func finish_dash(dir):
	global_position = target_position # Snap to target to avoid overshooting
	if sliding:
		start_dash(dir)
		return
		
	is_dashing = false
	animated_sprite.play("Idle")
	animated_sprite.flip_h = false # Reset flip when idle


func move_back_on_hurt(delta):
	var direction = (hurt_target_position - global_position).normalized()
	global_position += direction * DASH_SPEED * delta
	if global_position.distance_to(hurt_target_position) < 1:
		finish_hurt()


func handle_hurt():
	if is_alive:
		is_dashing = false
		hurt_movement_active = true
		hurt_target_position = start_pos # Move back to the start position of the dash
		animated_sprite.play("Hurt")

func finish_hurt():
	hurt_movement_active = false
	global_position = hurt_target_position # Snap to target to avoid overshooting
	animated_sprite.play("Idle")
	
func die():
	is_alive = false # Disable further actions
	animated_sprite.play("Die")

func win():
	print("CONGRATULATIONS YOU WIN!")
	is_alive = false
	animated_sprite.play("Celebrate")
	await get_tree().create_timer(2.0).timeout
	spawn_pos.x += 64*16
	get_node("../Camera2D").global_position.x += 64*16.5
	reset()


func _on_body_entered(body):
	if body.is_in_group("Wall") and is_dashing:
		handle_hurt()

func _on_area_entered(area):
	if area.is_in_group("Hazard"):
		die()
	elif area.is_in_group("Ice"):
		sliding = true
	elif area.is_in_group("Box"):
		handle_hurt()
		area.push_box((target_position - global_position).normalized())
	
		
	elif area.is_in_group("Goal"):
		win()

func _on_area_exited(area):
	if area.is_in_group("Ice"):
		sliding = false
		for area_col in get_overlapping_areas():
			if area_col.is_in_group("Ice"):
				sliding = true


#var second = false
func reset():
	#if second:
	get_tree().reload_current_scene()
	#second = true
	#global_position = spawn_pos
	#start_pos = global_position
	#target_position = global_position
	#is_alive = true
	#animated_sprite.play("Idle")
	


