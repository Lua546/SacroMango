extends Control

@onready var contador = $Mangos_contador/Texto/Contador

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Global.nivel = 1
	contador.text = str(Global.mangos)
