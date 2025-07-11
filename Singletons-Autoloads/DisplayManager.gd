extends Node

const BASE_RESOLUTION := Vector2i(480, 270)

func _ready():
	
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	var root := get_tree().root
	root.content_scale_size = BASE_RESOLUTION
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP

	var window := get_window()
	window.size = DisplayServer.screen_get_size()
	window.content_scale_size = BASE_RESOLUTION
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP

	print("DisplayManager inicializado com sucesso!")
