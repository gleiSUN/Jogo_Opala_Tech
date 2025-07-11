extends Node2D

@export var next_scene : String

func _on_next_level_body_entered(body):
	if body.is_in_group("Player"):
		var player = body as CharacterBody2D
		player.queue_free()
	
	GerenciadorDeCenas.transition_to_scene(next_scene)
