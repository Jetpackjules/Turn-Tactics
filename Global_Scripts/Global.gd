extends Node

func _input(event):
	if event.is_action_pressed("reset"):
		reset()


func reset():
	# Remove all nodes in the "Spawned" group
	for node in get_tree().get_nodes_in_group("Spawned"):
		node.queue_free()  # This will mark the node for deletion

	# Reset all nodes in the "Player" group
	for node in get_tree().get_nodes_in_group("Player"):
		if node.has_method("reset"):
			node.reset()  # Call the reset method if it exists

	# Reset all nodes in the "Player" group
	for node in get_tree().get_nodes_in_group("Active"):
		if node.has_method("start"):
			node.start()
