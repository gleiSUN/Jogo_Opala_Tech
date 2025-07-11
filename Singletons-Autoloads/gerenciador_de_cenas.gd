extends Node

var cenas : Dictionary = {
	"menu principal": "res://UI/menu_principal.tscn",
	"vila":"res://Worlds/scenes/vila/vila.tscn",
	"floresta":"res://Worlds/scenes/floresta/floresta.tscn"
}

func transition_to_scene(level : String):
	var scene_path :String = cenas.get(level)
	
	if scene_path != null:
		#await LoadingScreen.show_loading()
		
		get_tree().change_scene_to_file(scene_path)

		await get_tree().process_frame

		#await LoadingScreen.hide_loading()
