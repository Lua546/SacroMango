extends CharacterBody3D

@export var velocidad_patruya: float = 3.0  # Velocidad mientras patrulla
@export var velocidad_persecucion: float = 4.0  # Velocidad al perseguir
@export var puntos_patruya: Array[Vector3]  # Puntos de patrulla
@export var prefab_chancla: PackedScene  # Escena de la chancla

@onready var nav_agent = $NavigationAgent3D
@onready var area_perseguir = $AreaPerseguir
@onready var area_chancla = $AreaChancla
@onready var jugador = null  # Referencia al jugador cuando es detectado

var destino_actual = 0  # Índice del punto actual de patrulla
var patrulla_direccion = 1  # 1 = Avanza, -1 = Regresa
var lanzando_chancla = false  # Evita que lance muchas chanclas seguidas

func _ready():
	if puntos_patruya.is_empty():
		print("❌ ERROR: No hay puntos de patrullaje definidos.")
		return
	
	nav_agent.target_position = puntos_patruya[destino_actual]

	# Conectar señales de detección
	area_perseguir.body_entered.connect(_on_AreaPerseguir_body_entered)
	area_perseguir.body_exited.connect(_on_AreaPerseguir_body_exited)
	area_chancla.body_entered.connect(_on_AreaChancla_body_entered)

func _process(delta):
	if lanzando_chancla:
		return  # No hacer nada mientras lanza la chancla
	
	if jugador:
		perseguir_jugador(delta)  # Siempre persigue al jugador
	else:
		patrullar(delta)

func patrullar(delta):
	if global_position.distance_to(nav_agent.target_position) < 0.5:
		actualizar_destino_patruya()

	mover_hacia(nav_agent.get_next_path_position(), delta, velocidad_patruya)

func actualizar_destino_patruya():
	destino_actual += patrulla_direccion
	
	if destino_actual >= puntos_patruya.size():  
		destino_actual = puntos_patruya.size() - 2
		patrulla_direccion = -1  
	
	elif destino_actual < 0:  
		destino_actual = 1  
		patrulla_direccion = 1  
	
	nav_agent.target_position = puntos_patruya[destino_actual]

func perseguir_jugador(delta):
	if jugador:
		nav_agent.target_position = jugador.global_position
		mover_hacia(nav_agent.get_next_path_position(), delta, velocidad_persecucion)

func lanzar_chancla():
	lanzando_chancla = true
	
	var chancla = prefab_chancla.instantiate()  # Crea la chancla
	get_parent().add_child(chancla)  # La agrega a la escena
	chancla.global_position = global_position + Vector3.UP * 1  # Posición inicial
	chancla.disparar(jugador.global_position)  # Le dice a la chancla que ataque
	
	await get_tree().create_timer(2.0).timeout  # Espera 2 segundos antes de lanzar otra
	lanzando_chancla = false

func mover_hacia(destino: Vector3, delta, velocidad_actual):
	var direccion = (destino - global_position).normalized()
	
	if direccion.length() > 0.1:
		velocity = direccion * velocidad_actual
		move_and_slide()
	else:
		velocity = Vector3.ZERO

func _on_AreaPerseguir_body_entered(body):
	if body.name == "Jugador":
		jugador = body
		print("🔴 Jugador detectado. Persiguiendo...")

func _on_AreaPerseguir_body_exited(body):
	if body == jugador:
		jugador = null
		destino_actual = 0
		patrulla_direccion = 1  
		nav_agent.target_position = puntos_patruya[destino_actual]
		print("🟢 Jugador fuera del área. Volviendo a patrullar.")

func _on_AreaChancla_body_entered(body):
	if body.name == "Jugador" and not lanzando_chancla:
		jugador = body
		lanzar_chancla()
