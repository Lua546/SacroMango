extends RigidBody3D

var velocidad = 10.0
var objetivo = Vector3.ZERO

func _ready():
	$Timer.timeout.connect(_on_Timer_timeout)

func disparar(posicion_objetivo):
	objetivo = posicion_objetivo
	var direccion = (objetivo - global_position).normalized()
	apply_impulse(direccion * velocidad)  # Lanza la chancla hacia el jugador

func _on_Timer_timeout():
	queue_free()  # Destruir la chancla después de un tiempo


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Jugador":
		await get_tree().create_timer(0.1).timeout
		queue_free()
