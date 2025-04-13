extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export_group("camera")
@export_range(0.0,1.0) var mouse_sensitivity := 0.25

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var jump_impulse := 12.0
@export var rotation_speed := 12

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0

@onready var _camera_pivot: Node3D = %Camera_pivot
@onready var _camera: Camera3D = %Camera3D
@onready var piel = %Piel
@onready var salida = $Camera_pivot/Camara_tiro/RayCast3D
@onready var camara_anim = $Camera_pivot/SpringArm3D/Camera3D/AnimationPlayer

@onready var cam_atras = %Camera3D
@onready var cam_tiro = $Camera_pivot/Camara_tiro

@onready var puntero = $Puntero

var moviendo = false
var direccion = 0
var mouse_quieto = false
var modo_tirar = false

var mango = load("res://Objetos/Proyectil/proyectil.tscn")
var instance

func _ready() -> void:
	piel.show()
	_camera_pivot.rotation.x = -25
	puntero.hide()
	modo_tirar = false
	cam_atras.current = true
	cam_tiro.current = false
	

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	
	#Modo tirar------------------------------------------------------------------------------
	if Input.is_action_just_pressed("apuntar"):
		camara_anim.play("acercar")
		
	
	if modo_tirar == false and Input.is_action_pressed("apuntar"):
		modo_tirar = true
		_camera_pivot.rotation.x = 0
			
	if modo_tirar:
		move_speed = 4.0
		puntero.show()
		
		
		if Input.is_action_just_pressed("disparar"):
			Global.mangos -= 1
			instance = mango.instantiate()
			instance.position = salida.global_position
			instance.transform.basis = salida.global_transform.basis
			get_parent().add_child(instance)
		
		if Input.is_action_just_released("apuntar"):
			modo_tirar= false
			_camera_pivot.rotation.x = -25
			cam_atras.current = true
			cam_tiro.current = false
			camara_anim.play("alejar")
			
	else:
		move_speed = 8.0
		puntero.hide()
	#Movimiento de la camara-----------------------------------------------------------------
	
	#En el siguien bloque de codigo configuro la camara segun el modo (modo normal/modo tiro)
	if modo_tirar:
		#Si el juego está en modo tirar
		piel.hide()
		_camera_pivot.rotation.x -= _camera_input_direction.y * delta 
		_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 4.0, PI / 5) #<-- Limita el giro de la camara
	else:
		#Si el juego está en modo normal
		piel.show()
		_camera_pivot.rotation.x += _camera_input_direction.y * delta
		_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 5.0, PI / 18) #<-- Limita el giro de la camara

	_camera_pivot.rotation.y -= _camera_input_direction.x * delta

	_camera_input_direction = Vector2.ZERO
	
	#Ocultar o mostrar el mouse-------------------------------------------------------------
	if Input.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_quieto = false
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouse_quieto = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	#Movimiento del jugador-----------------------------------------------------------------
	var raw_input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity + _gravity * delta
	
	var is_starting_jump := Input.is_action_just_pressed("ui_accept") and is_on_floor()
	if is_starting_jump:
		velocity.y += jump_impulse
		
	move_and_slide()
	
	#Animación del jugador------------------------------------------------------------
	var ground_speed := Vector2(velocity.x, velocity.z).length()
	print(ground_speed)
	if ground_speed > 0.0:
		piel.correr()
	else:
		piel.esperar()
	
	#Rotar movimiento-----------------------------------------------------------------
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var _target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	piel.global_rotation.y = lerp_angle(piel.rotation.y, _target_angle, rotation_speed * delta)
	
	
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"acercar":
			cam_atras.current = false
			cam_tiro.current = true
		
