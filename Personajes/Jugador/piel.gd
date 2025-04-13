extends Node3D

@onready var animation_tree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
var current_state := ""  # Guarda el estado actual

func _ready():
	animation_tree.active = true
	esperar() # Estado inicial

func correr():
	state_machine.travel("Correr")
	#if current_state != "Correr":
		#print("Transición a CORRER")
		#state_machine.travel("Correr")
		#current_state = "Correr"

func esperar():
	state_machine.travel("Esperar")
	#if current_state != "Esperar":
		#print("Transición a ESPERAR")
		#state_machine.travel("Esperar")
		#current_state = "Esperar"
