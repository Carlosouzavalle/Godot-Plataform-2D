extends Area2D

export var fruits = 1


func _on_item_body_entered(_body):
	$anim.play("collected")
	Global.fruits += fruits
	print(Global.fruits)
	


func _on_anim_animation_finished(anim_name):
	if anim_name == "collected":
		queue_free()
