extends Area2D


func _on_fallzone_body_entered(body):
	get_tree().reload_current_scene()
#	get_tree().change_scene("res://Levels/Level_02.tscn")
#caso tivesse um lv2 a linha acima iria mudar a fase


	
