extends Control

func _on_Ok_pressed():
	var _scene=get_tree().change_scene("res://Game project/Cenas/Network Setup.tscn")
func set_text(text) -> void:
	$Label.text = text
