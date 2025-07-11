extends Node


func restart_game():
	get_tree().reload_current_scene()

func return_to_menu():
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
