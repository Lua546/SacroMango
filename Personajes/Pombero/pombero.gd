extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const TURN_SPEED = 4.0

var camara
var direccion
var instance
var player

var random = RandomNumberGenerator.new()

var caña = load("res://Objetos/Caña/caña.tscn")



@onready var salida = $"Sprite3D/Tira_caña"
@onready var sprite_anim = $Sprite3D/AnimationPlayer
@onready var animator = $AnimationPlayer

@export var player_path : NodePath

func _physics_process(delta: float) -> void:
	camara = Global.camara_rotacion
	player = Global.jugador_posicion
	
	#$Sprite3D.set_billboard_mode(2)
	#animator.play("girando")
	
	#controlar_rotacion(camara)
	control_sprite(direccion)
	direccion = 270
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()
	
func control_sprite(direccion):
	match direccion:
		90:
			sprite_anim.play("caminando_espalda")
		270:
			sprite_anim.play("caminando_frente")
		180:
			sprite_anim.play("caminando_perfil")
			$Sprite3D.flip_h = false
		0:
			sprite_anim.play("caminando_perfil")
			$Sprite3D.flip_h = true

func controlar_rotacion(camara):
	if camara == 0:
		direccion = 90
	elif camara == 1:
		direccion = 180
	elif camara == -1:
		direccion = 0
	elif camara < 1:
		direccion = 270
	

func tirar():
	look_at(Vector3(player.x,player.y,player.z), Vector3.UP)
	#objetivo aleatorio-----------
	#var d = random.randf_range(0, 360)
	#var target = Vector3(0,d,0)
	#$Sprite3D.rotation = $Sprite3D.rotation.lerp(target, TURN_SPEED)
	#tirar caña-------------------
	instance = caña.instantiate()
	instance.position = salida.global_position
	instance.transform.basis = salida.global_transform.basis
	get_parent().add_child(instance)


func _on_timer_disparo_timeout() -> void:
	tirar()
