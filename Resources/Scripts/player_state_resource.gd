class_name PlayerState
extends Resource

signal repel_requested(source: Vector2)

## The player's current position in the world
## (Must only be updated by the current player controller)
var m_position: Vector2


#region Functions

## In more advanced systems, these methods may also have
## additional checks to prevent something from going awry
func repel_nearby() -> void:
    repel_requested.emit(m_position)