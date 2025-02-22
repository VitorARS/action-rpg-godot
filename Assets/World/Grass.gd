extends Node2D

const GrassEffect = preload("res://Assets/Effects/GrassEffect.tscn" )

func _create_grass_effect():
	
	 var grassEffect = GrassEffect.instance()                                                     #se vc arrastar um cena no script ele diz onde achala
	 get_parent().add_child(grassEffect)
	 grassEffect.global_position = global_position



func _on_Hurtbox_area_entered(area):
	_create_grass_effect()
	queue_free()
