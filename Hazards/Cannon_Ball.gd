extends Area2D

var TILE_SIZE = 64 # Adjust to your tile size
var direction = Vector2.ZERO
var speed = 800 # Assuming player's speed is 200, adjust as needed
var target_position = Vector2.ZERO
var is_moving = false

var fired = true

@onready var animation_player = $AnimatedSprite2D

var fired_pos

func _ready():
	fired_pos = global_position
	Tick.pass_tick.connect(_on_tick)
	_on_tick(1)
	

func _process(delta):
	if is_moving and !exploded:
		move_cannonball(delta)

func move_cannonball(delta):
	var move_step = speed * delta
	global_position = global_position.move_toward(target_position, move_step)
	if global_position.distance_to(fired_pos) > 64:
		fired = false
	if global_position.distance_to(target_position) < 1:
		global_position = target_position
		is_moving = false
		if not is_inside_tree(): # Stop if cannonball is no longer in the scene
			queue_free()

func _on_tick(ticks):
	if not is_moving:
		target_position = global_position + direction * TILE_SIZE * 2
		is_moving = true

var exploded = false

func _on_body_entered(body):
	if body.is_in_group("Wall") and !fired:
		explode()

func _on_area_entered(area):
	if area.is_in_group("Player") or area.is_in_group("Box"):
		explode()




func explode():
	exploded = true
	animation_player.play("Explode")

func _on_animated_sprite_2d_animation_finished():
	if exploded:
		queue_free()
