extends Node2D

# Paths to your scenes and tilemap
@export var PlayerScene: PackedScene
@export var CannonScene: PackedScene
@export var BoxScene: PackedScene
@export var GoalScene: PackedScene
@export var IceScene: PackedScene

@onready var tilemap: TileMap = get_node("TileMap")

# Size of each tile in pixels
const TileSize = Vector2(54, 54)

var wall_pos_array: Array = []
var placeholder_tile := Vector2i(9,4)

# Level data (you can replace this with any level layout)
var level_data = [
"WWWWWWWWWWWWWWWWWWWW",
"W..........W.......G",
"WBWWWWWWWWWW.CBWWWWW",
"WPBIBIBIBIBIBIBIBIIW",
"WWWWWWWWWWWWW.C.WWWW",
"W..........W.......W",
"W.C.WWWWWWWWWWWWWWWW",
"W...W.....C...B....W",
"WWWWWWWWWWWWWW.C.WWW",
"WWWWWWWWWWWWWWWWWWWW",
]



func _ready():
	clear_level()
	build_level()

func clear_level():
	wall_pos_array.clear()
	return
	for child in get_children():
		child.queue_free()

func build_level():
	var total_rows = len(level_data) + 10 # 5 rows of walls on each side
	var total_columns = level_data[0].length() + 10 # 5 columns of walls on each side

	for y in range(total_rows):
		for x in range(total_columns):
			var tile_position = Vector2(x, y) * TileSize
			if x < 5 or x >= total_columns - 5 or y < 5 or y >= total_rows - 5: #ADDING BORDER WALL TILES
				wall_pos_array.append(Vector2i(x,y))
				tilemap.set_cell(0, Vector2i(x,y), 0, placeholder_tile)
			else:
				# Use level_data for inner tiles
				var char = level_data[y - 5][x - 5]
				spawn_object(char, tile_position)
				

	tilemap.set_cells_terrain_connect(0, wall_pos_array, 0, 0, false)

	
func spawn_object(char, obj_position):
	var scene = null
	match char:
		'P':
			scene = PlayerScene
		'C':
			scene = CannonScene
		'B':
			scene = BoxScene
		'G':
			scene = GoalScene
		'I':
			scene = IceScene
		'W':
			# For walls, we use the tilemap
			if (obj_position / TileSize) in wall_pos_array:
				print("WTF!")
				print(obj_position/TileSize)
				
				
			wall_pos_array.append(obj_position / TileSize)
			tilemap.set_cell(0, obj_position / TileSize, 0, placeholder_tile)
			
			return
		'.':
			return # Empty space, do nothing

	if scene:
		var instance = scene.instantiate()
		instance.position = obj_position+TileSize/2
		add_child(instance)
