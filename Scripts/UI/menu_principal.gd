extends Control

@onready var UI_Jogar = $Ui/VBoxContainer/BotaoJogar
@onready var UI_Sair = $Ui/VBoxContainer/BotaoSair

func _ready():
	UI_Jogar.pressed.connect(_on_jogar_pressed)
	UI_Sair.pressed.connect(_on_sair_pressed)

func _on_jogar_pressed():
	GerenciadorDeCenas.transition_to_scene("vila")

func _on_sair_pressed():
	get_tree().quit()
