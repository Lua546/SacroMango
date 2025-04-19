extends Control

@onready var barra = $TextureProgressBar

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	barra.value = Global.pom_vida
	#$Label.text = str(Global.vida)
