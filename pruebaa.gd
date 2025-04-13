extends Node3D

@onready var jugador = $Jugador
var direccion

var switch = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.mangos = 100
	Global.vida = 100
	Global.pom_vida = 150
	Global.fase = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Global.jugador_posicion = jugador.global_transform.origin
	
	if Global.vida < 70:
		Global.fase = 2
	
	if Global.fase == 2 and switch == 0:
		$Bloques_grandes/AnimationPlayer.play("salir")
		switch = 1
		
	
	
