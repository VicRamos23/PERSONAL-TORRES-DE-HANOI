extends RigidBody2D

var is_holding_disk = false
var current_tower = null
@onready var nave = get_tree().get_root().get_node_or_null("/root/scenemainprincipal/nave")
@onready var torre1 = get_tree().get_root().get_node_or_null("/root/scenemainprincipal/Torres/torre1")
@onready var torre2 = get_tree().get_root().get_node_or_null("/root/scenemainprincipal/Torres/torre2")
@onready var torre3 = get_tree().get_root().get_node_or_null("/root/scenemainprincipal/Torres/torre3")

const TOWER_SNAP_DISTANCE = 1  # Distancia máxima para "adherirse" a una torre

func _ready():
	gravity_scale = 1.0
	print("Disco inicializado")
	print("Estado de las torres:")
	print_tower_status(torre1, "Torre 1")
	print_tower_status(torre2, "Torre 2")
	print_tower_status(torre3, "Torre 3")
	print("Estado de la nave:")
	print_tower_status(nave, "Nave")

func print_tower_status(node: Node, name: String):
	if node != null:
		print(name + " encontrada en posición: " + str(node.global_position))
	else:
		print(name + " no encontrada (null)")

func _process(delta):
	if Input.is_action_just_pressed("ui_up") and not is_holding_disk:
		if is_below_nave():
			lift_disk()
	
	if Input.is_action_just_pressed("ui_down") and is_holding_disk:
		release_disc()

func is_below_nave() -> bool:
	if nave == null:
		print("Error: La nave es null")
		return false
	var distance_x = abs(nave.global_position.x - global_position.x)
	var distance_y = nave.global_position.y - global_position.y
	var aligned_in_x = distance_x < 30
	var within_range_in_y = abs(distance_y) < 50
	return aligned_in_x and within_range_in_y

func lift_disk():
	is_holding_disk = true
	gravity_scale = 0.0
	linear_velocity = Vector2.ZERO
	print("Disco levantado")

func _physics_process(_delta):
	if is_holding_disk:
		if nave != null:
			global_position.x = nave.global_position.x
			global_position.y = nave.global_position.y - 320
			print("Disco en posición: ", global_position)
		else:
			print("Error: La nave es null en _physics_process")

func release_disc():
	print("Intentando soltar el disco en posición: ", global_position)
	var torre_destino = get_tower_at_position()
	if torre_destino:
		print("Torre destino encontrada: ", torre_destino.name)
		if can_drop_disc(torre_destino):
			drop_on_tower(torre_destino)
		else:
			print("No se puede soltar el disco: el disco en la torre es más pequeño.")
			reset_position()
	else:
		print("No estás sobre una torre válida.")
		reset_position()

func get_tower_at_position() -> Node2D:
	for torre in [torre1, torre2, torre3]:
		if torre != null:
			var distance = global_position.distance_to(torre.global_position)
			print("Distancia a ", torre.name, ": ", distance)
			if distance <= TOWER_SNAP_DISTANCE:
				return torre
		else:
			print("Una torre es null en get_tower_at_position")
	print("No se encontró torre en la posición actual")
	return null

func can_drop_disc(torre_destino: Node2D) -> bool:
	var top_disc = null
	for child in torre_destino.get_children():
		if child is RigidBody2D and child != self:
			top_disc = child
	if top_disc and top_disc.scale.x < scale.x:
		return false
	return true

func drop_on_tower(torre_destino: Node2D):
	freeze = false
	is_holding_disk = false
	gravity_scale = 1.0
	global_position.x = torre_destino.global_position.x
	align_disc_on_tower(torre_destino)
	print("Disco soltado en torre ", torre_destino.name, " en posición: ", global_position)

func align_disc_on_tower(torre_destino: Node2D):
	var num_discs = 0
	for child in torre_destino.get_children():
		if child is RigidBody2D and child != self:
			num_discs += 1
	var y_offset = 30  # Ajusta este valor según el tamaño de tus discos
	global_position.y = torre_destino.global_position.y - (num_discs * y_offset) - 15

func reset_position():
	is_holding_disk = false
	gravity_scale = 1.0
	# Aquí puedes añadir lógica para devolver el disco a su posición original
	print("Reseteando posición del disco")
