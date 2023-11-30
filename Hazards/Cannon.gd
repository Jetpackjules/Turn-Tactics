extends Area2D

var tick_count = 0
var cannonball_scene = preload("res://Hazards/Cannon_Ball.tscn")


@onready var cannon_sprite = $Sprite2D 

func _ready():
	Tick.pass_tick.connect(_on_tick)
	start()
	
func _on_tick(ticks):
	tick_count += ticks
	if tick_count == 4:
		# Change color to bright red the turn before firing
		cannon_sprite.modulate = Color(1, 0, 0) # Bright red
	elif tick_count >= 5:
		fire_cannonball()
		tick_count = 0
		reset_cannon_color()

func fire_cannonball():
	var cannonball = cannonball_scene.instantiate()
	# cannonball.global_position = global_position # Adjust as needed
	cannonball.direction =  Vector2(cos(rotation), sin(rotation))
	add_child(cannonball)

func reset_cannon_color():
	# Reset the color of the cannon to its original state
	cannon_sprite.modulate = Color(1, 1, 1) # Normal color

func start():
	reset_cannon_color() # Ensure the cannon starts with its default color
	tick_count = 0
	_on_tick(4)
