extends KinematicBody2D

#=======================================VARIAVEIS=======================================

var UP = Vector2.UP # com essa variavel noss player sabe aonde é a direção para cima
var velocity = Vector2() #Vector2.ZERO tbm funciona
var move_speed = 480
var gravity = 1200 
var jump_force = -720
var is_grounded
export var player_health = 3 # são 4 vidas aqui mais quando o jogo iniciar vamos ter 3
var max_health = 3
var hurted = false
var knockback_dir = 1 # é a direção que do empurão 
var knockback_int = 1000 # 300  aqui é a intensidade dele
onready var raycasts = $raycasts
signal change_life(player_health)
#==================================END_VARIAVEIS=======================================

#=======================================READY============================================
func _ready():
	connect("change_life", get_parent().get_node("HUD/HBoxContainer/Holder"), "on_change_life")
	emit_signal("change_life", max_health)
	position.x = Global.checkpoint_pos

#==================================END_READY============================================
	

#==================================PHYSICS_PROCESS=========================================		
func _physics_process(delta):
	#$anim.play("Idle") # vai fazer tocar a animação de player
	velocity.y += gravity * delta
	velocity.x = 0
	
	if !hurted:
		_get_input()
	
	velocity = move_and_slide(velocity, UP)		
	
	is_grounded = _check_is_grounded()
	
	_set_animation()
	
#	for platforms in get_slide_count():
#		var collision = get_slide_collision(platforms)
#		if collision.collider.has_method("collide_with"):
#			collision.collider.collide_with(collision, self)

#===============================END_PHYSICS_PROCESS================================================

#=======================================FUNÇÔES===================================================
func _get_input():
	velocity.x = 0
	var move_direction = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, 0.2)

	if move_direction != 0:
		$texture.scale.x = move_direction # assim ele vai saber quando esta para direita ou para esquerda
		knockback_dir = move_direction
		
func _input(event):
	if event.is_action_pressed("jump") and is_grounded:
		velocity.y = jump_force / 2
		
func _check_is_grounded():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true		
	return false
				

func _set_animation():
	var anim = "Idle"
	if !is_grounded:
		anim  = "jump"
	elif velocity.x != 0:
		anim = "Run"
	if velocity.y > 0 and !is_grounded:
		anim = "fall"
	if hurted:
		anim = "hit"	
	if $anim .assigned_animation != anim:
		$anim.play(anim)

		
func knockback():
	if $right.is_colliding():
		velocity.x = -knockback_dir * knockback_int
	if $left.is_colliding():
		velocity.x = knockback_dir * knockback_int
	velocity = move_and_slide(velocity)
	
func _on_hurtbox_body_entered(_body):
	player_health -= 1 # aqui a gente subtrair a nossa vida
	print(player_health) # vai nos mostrar quanto de hp começamos
	hurted = true
	knockback()
	emit_signal("change_life", player_health)
	yield(get_tree().create_timer(0.5), "timeout")
	hurted = false
	if player_health < 1: 
		queue_free()
		get_tree().reload_current_scene()
		
		
func hit_checkpoint():
	Global.checkpoint_pos = position.x
	print(position.x)

#====================================END_FUNÇÔES===================================================


func _on_HeadCollider_body_entered(body):
	if body.has_method("destroy"):
		body.destroy()
