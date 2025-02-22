extends KinematicBody2D


const PlayerDeathSound = preload ("res://arqdojogo/Player/MeDerrubaramSound.tscn")
const PlayerHurtsound = preload("res://arqdojogo/Player/PlayerHurtSound.tscn")
export var ROLL_SPEED = 110
export var VELOCIDADE_MAX = 55
export var ACELERACAO = 250
export var ATRITO = 400
enum {
	MOVE,
	ROLL,
	ATTACK
}
var velocidade = Vector2.ZERO
var state = MOVE
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animacaoJogador = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get('parameters/playback' )
onready var swordHitbox = $HitboxPivet/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	randomize()
	stats.connect('no_health', self, 'queue_free')
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

	
func _physics_process(delta):
	match state:                       #isso aq é state machine 
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)



func move_state(delta):
	var resultante = Vector2.ZERO
	resultante.x = Input.get_action_strength("ui_right") - Input.get_action_strength('ui_left')
	resultante.y = Input.get_action_strength("ui_down") - Input.get_action_strength('ui_up')
	resultante = resultante.normalized()
	 
	if resultante!= Vector2.ZERO:
		roll_vector = resultante
		swordHitbox.knockback_vector = resultante
		animationTree.set('parameters/correndo/blend_position', resultante )
		animationTree.set('parameters/Parado/blend_position', resultante )
		animationTree.set('parameters/Attack/blend_position', resultante )
		animationTree.set('parameters/Roll/blend_position', resultante )
		velocidade = velocidade.move_toward( resultante * VELOCIDADE_MAX,  ACELERACAO * delta)
		animationState.travel('correndo')
	
	else:
		velocidade = velocidade.move_toward(Vector2.ZERO, ATRITO * delta)
		animationState.travel('Parado')
	
	move()
	
	velocidade =  move_and_slide(velocidade)
	
	if Input. is_action_just_pressed("Roll"):
		 state = ROLL
	 
	if Input.is_action_just_pressed("attack"):  
		state = ATTACK
	
func roll_state(delta):
	velocidade = roll_vector * ROLL_SPEED
	animationState.travel('Roll')
	move()
	
func attack_state(delta):   # se aparecer um erro too many arguments foi pq eu esqueci de colocar entre parentes na funçao
	animationState.travel('attack')
	velocidade = Vector2.ZERO
	
func move():
	velocidade =  move_and_slide(velocidade)
	
func roll_animation_finished():
	velocidade = velocidade * 0.7
	state = MOVE
	
	
func attack_animation_finished():
	
	state = MOVE
	
func _on_Hurtbox_area_entered(area):
	stats.health -=area.damage
	hurtbox._start_invincibility(0.6)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtsound.instance()
	get_tree().current_scene.add_child(playerHurtSound) 
	


func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start" )


func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
