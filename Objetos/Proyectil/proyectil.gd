extends Node3D

const SPEED = 15

@onready var mesh = $blockbench_export
@onready var ray = $RayCast3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0,-SPEED) * delta
	#if $RayCast3D.is_colliding():
		#queue_free()

func _on_timer_timeout() -> void:
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	Global.pom_vida -= 5
	queue_free()
