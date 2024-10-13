extends Control


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://SCENES/scenemainprincipal.tscn")

func _on_reglas_pressed() -> void:
	get_tree().change_scene_to_file("res://SCENES/options.tscn")

func _on_creditos_pressed() -> void:
	get_tree().change_scene_to_file("res://SCENES/creditos.tscn")
	
