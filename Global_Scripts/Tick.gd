extends Node

signal pass_tick(num_ticks)

func run_tick(ticks):
	pass_tick.emit(ticks)
