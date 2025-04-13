extends Node3D

const SPEED = 5

func _ready() -> void:
	$AnimationPlayer.play("Girar")

func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,-SPEED,0) * delta
	#if $RayCast3D.is_colliding():
		#queue_free()


func _on_timer_timeout() -> void:
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	Global.vida -= 10
	queue_free()
