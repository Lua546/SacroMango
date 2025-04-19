extends CharacterBody3D

const SPEED = 3.0
const CHARGE_SPEED = 10.0
const CHARGE_DURATION = 1

var target_position = Vector3.ZERO
var instance
var player
var charge_direction = Vector3.ZERO
var charge_timer = 0.0
var caña = load("res://Objetos/Caña/caña.tscn")

@onready var salida = $"Sprite3D/Tira_caña"
@onready var sprite_anim = $Sprite3D/AnimationPlayer
@onready var animator = $AnimationPlayer

@export var player_path : NodePath

enum State {
	IDLE,
	CHARGING,
	WAIT_AFTER_CHARGE,
	THROW,
	WAIT_AFTER_THROW
}

var state = State.IDLE
var wait_timer: Timer

func _ready():
	wait_timer = Timer.new()
	wait_timer.one_shot = true
	add_child(wait_timer)
	wait_timer.timeout.connect(_on_wait_timer_timeout)

func _physics_process(delta: float) -> void:
	player = Global.jugador_posicion
	var jugador = get_node(player_path)
	target_position = jugador.global_transform.origin
	
	var direction = (target_position - global_transform.origin).normalized()

	match state:
		State.IDLE:
			# Nada por ahora
			start_charge()

		State.CHARGING:
			sprite_anim.play("caminando_frente")
			velocity = charge_direction * CHARGE_SPEED
			charge_timer -= delta
			if charge_timer <= 0.0:
				velocity = Vector3.ZERO
				state = State.WAIT_AFTER_CHARGE
				wait_timer.start(1.0)  # Espera 1 segundo antes de tirar la caña

		State.WAIT_AFTER_CHARGE:
			velocity = Vector3.ZERO

		State.THROW:
			tirar()
			state = State.WAIT_AFTER_THROW
			wait_timer.start(1.0)  # Espera 1 segundo antes de volver a embestir

		State.WAIT_AFTER_THROW:
			velocity = Vector3.ZERO

	# Gravedad si está en el aire
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func start_charge():
	var jugador = get_node(player_path)
	target_position = jugador.global_transform.origin
	charge_direction = (target_position - global_transform.origin).normalized()
	charge_timer = CHARGE_DURATION
	state = State.CHARGING

func tirar():
	look_at(Vector3(player.x, player.y, player.z), Vector3.UP)
	instance = caña.instantiate()
	instance.position = salida.global_position
	instance.transform.basis = salida.global_transform.basis
	get_parent().add_child(instance)

func _on_wait_timer_timeout():
	if state == State.WAIT_AFTER_CHARGE:
		state = State.THROW
	elif state == State.WAIT_AFTER_THROW:
		start_charge()
