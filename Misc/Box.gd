extends Area2D

# Constants
const TILE_SIZE = 54 # Change this to your tile size
const MOVE_TIME = 0.2 # Time in seconds to move one tile

const MOVE_SPEED = 400 # Speed of the movement, adjust as needed

# Member Variables
var target_position: Vector2
var start_position: Vector2
var direction: Vector2 # Universal direction variable
var is_moving: bool = false
var sliding: bool = false # Ice slide

# Variables for handling bounce movement
var bounce_movement_active: bool = false
var bounce_target_position: Vector2

func _ready():
	reset()

func _process(delta):
	if is_moving:
		move_towards_target(delta)
	elif bounce_movement_active:
		move_back_on_bounce(delta)
		
	if sliding:
		#print(delta)
		pass

func move_towards_target(delta):
	#direction = (target_position - global_position).normalized()
	global_position += direction * MOVE_SPEED * delta

	if global_position.distance_to(target_position) < 4:
		finish_move()

func finish_move():
	global_position = target_position # Snap to target to avoid overshooting
	if sliding:
		start_move(direction)
		return

	is_moving = false
	

func start_move(dir: Vector2):
	direction = dir # Update the universal direction variable
	start_position = global_position
	target_position = global_position + direction * TILE_SIZE
	is_moving = true

func push_box(dir: Vector2):
	if !is_moving:
		start_move(dir)
		#Tick.run_tick(1) # Assuming you have a similar Tick system for the box

func _on_body_entered(body):
	if body.is_in_group("Wall") and is_moving:
		handle_bounce()


func move_back_on_bounce(delta):
	global_position += direction * MOVE_SPEED * delta
	if global_position.distance_to(bounce_target_position) < 1:
		finish_bounce()


func handle_bounce():
	sliding = false
	is_moving = false
	bounce_movement_active = true

	bounce_target_position = start_position # Move back to the start position of the dash
	direction = (bounce_target_position - global_position).normalized()

func finish_bounce():
	bounce_movement_active = false
	global_position = bounce_target_position # Snap to target to avoid overshooting











func _on_area_entered(area):
	if area.is_in_group("Ice"):
		sliding = true
	elif area.is_in_group("Box") and is_moving:
		if !area.is_moving and !area.bounce_movement_active:
			area.push_box(direction) # Use the universal direction variable
		if !area.bounce_movement_active:
			handle_bounce()


func reset():
	target_position = global_position
	is_moving = false
	direction = Vector2.ZERO # Initialize direction


func _on_area_exited(area):
	if area.is_in_group("Ice"):
		sliding = false
		for area_col in get_overlapping_areas():
			if area_col.is_in_group("Ice"):
				sliding = true
