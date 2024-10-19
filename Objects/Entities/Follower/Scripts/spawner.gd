extends Node

@export
var p_template: PackedScene

@export
var m_max_instances := 32

var p_positions: Array[Vector2]
var p_spawn_timer: Timer

var m_instances := 0


#region Events

func _ready() -> void:
    p_spawn_timer = Timer.new()
    p_spawn_timer.wait_time = randf_range(0.5, 1.5)
    p_spawn_timer.one_shot = false

    # Cache positions
    for child: Node in get_children():
        if child is not Node2D:
            continue

        p_positions.append(child.global_position)

    p_spawn_timer.timeout.connect(_on_spawn)

    # Finalise setup
    add_child.call_deferred(p_spawn_timer)
    p_spawn_timer.start.call_deferred()


func _on_spawn() -> void:
    p_spawn_timer.wait_time = randf_range(0.5, 1.5)

    # [case] Prevent over-spawning
    if m_instances >= m_max_instances:
        return

    m_instances += 1

    # Spawn an instance at a random spawn point
    var instance: Node2D = p_template.instantiate()

    get_tree().current_scene.add_child.call_deferred(instance)
    instance.set_deferred(&"global_position", p_positions.pick_random())

    instance.unalived.connect(_on_instance_unalived)


func _on_instance_unalived() -> void:
    m_instances = max(0, m_instances - 1)