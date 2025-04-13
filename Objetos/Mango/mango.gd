extends Area3D

func _ready() -> void:
	$AnimationPlayer.play("Estatico")

func _on_body_entered(body: Node3D) -> void:
	Global.mangos += 1
	$AnimationPlayer.play("Desaparecer")
	await $AnimationPlayer.animation_finished
	queue_free()
