extends Node


func restart_game():
	get_tree().reload_current_scene()

func return_to_menu():
	GerenciadorDeCenas.transition_to_scene("menu principal")
