extends Node3D
const ARENA := 28.0
const SPEED := 10.0
var car: Node3D
var camera: Camera3D
var coins: Array[Node3D] = []
var velocity := Vector3.ZERO
var score := 0
var score_label: Label
var rng := RandomNumberGenerator.new()

func _ready() -> void:
 _setup_input()
 rng.randomize()
 _world()
 _car()
 _camera()
 _ui()
 for i in 12: _spawn_coin()

func _setup_input() -> void:
 var bindings := {"ui_up": KEY_W, "ui_down": KEY_S, "ui_left": KEY_A, "ui_right": KEY_D}
 for action in bindings:
  var key := InputEventKey.new()
  key.physical_keycode = bindings[action]
  InputMap.action_add_event(action, key)

func _world() -> void:
 var env_node := WorldEnvironment.new()
 var env := Environment.new()
 env.background_mode = Environment.BG_COLOR
 env.background_color = Color(0.10,0.16,0.22)
 env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color = Color(0.72,0.78,0.88)
 env_node.environment = env
 add_child(env_node)
 var sun := DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-55,-35,0)
 sun.light_energy = 1.3
 sun.shadow_enabled = true
 add_child(sun)
 var floor := MeshInstance3D.new()
 var fm := BoxMesh.new()
 fm.size = Vector3(ARENA,0.4,ARENA)
 floor.mesh = fm
 floor.position.y = -0.2
 var mat := StandardMaterial3D.new()
 mat.albedo_color = Color(0.16,0.39,0.29)
 floor.material_override = mat
 add_child(floor)
 for i in range(-12,13,2):
  _line(Vector3(i,0.012,-13.5),Vector3(i,0.012,13.5))
  _line(Vector3(-13.5,0.012,i),Vector3(13.5,0.012,i))
 for side in 4:
  var wall := MeshInstance3D.new()
  var box := BoxMesh.new()
  box.size = Vector3(29,1.1,0.7) if side < 2 else Vector3(0.7,1.1,29)
  wall.mesh = box
  wall.position = [Vector3(0,0.55,-14),Vector3(0,0.55,14),Vector3(-14,0.55,0),Vector3(14,0.55,0)][side]
  var wm := StandardMaterial3D.new()
  wm.albedo_color = Color(0.08,0.17,0.22)
  wall.material_override = wm
  add_child(wall)

func _line(a: Vector3,b: Vector3) -> void:
 var mesh := ImmediateMesh.new()
 mesh.surface_begin(Mesh.PRIMITIVE_LINES)
 mesh.surface_add_vertex(a)
 mesh.surface_add_vertex(b)
 mesh.surface_end()
 var node := MeshInstance3D.new()
 node.mesh = mesh
 var m := StandardMaterial3D.new()
 m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 m.albedo_color = Color(0.28,0.52,0.39)
 node.material_override = m
 add_child(node)

func _car() -> void:
 car = Node3D.new()
 add_child(car)
 _car_box(Vector3(0,0.58,0),Vector3(1.35,0.48,2.2),Color(0.08,0.38,0.92))
 _car_box(Vector3(0,0.98,-0.12),Vector3(1.05,0.48,1.05),Color(0.35,0.72,0.96))
 _car_box(Vector3(0,0.61,-1.12),Vector3(0.72,0.18,0.06),Color(1,0.9,0.5))
 _car_box(Vector3(0,0.61,1.12),Vector3(0.72,0.18,0.06),Color(0.95,0.12,0.06))
 for x in [-0.72,0.72]:
  for z in [-0.72,0.72]:
   var w := MeshInstance3D.new()
   var c := CylinderMesh.new()
   c.top_radius=0.28
   c.bottom_radius=0.28
   c.height=0.18
   w.mesh=c
   w.rotation_degrees.z=90
   w.position=Vector3(x,0.32,z)
   var m:=StandardMaterial3D.new()
   m.albedo_color=Color(0.02,0.025,0.03)
   w.material_override=m
   car.add_child(w)

func _car_box(p: Vector3,s: Vector3,color: Color) -> void:
 var n:=MeshInstance3D.new()
 var b:=BoxMesh.new()
 b.size=s
 n.mesh=b
 n.position=p
 var m:=StandardMaterial3D.new()
 m.albedo_color=color
 m.metallic=0.2
 m.roughness=0.3
 n.material_override=m
 car.add_child(n)

func _camera() -> void:
 camera=Camera3D.new()
 camera.projection=Camera3D.PROJECTION_ORTHOGONAL
 camera.size=25
 add_child(camera)
 camera.current=true
 _follow_camera()

func _follow_camera() -> void:
 camera.position=car.position+Vector3(13,16,13)
 camera.look_at(car.position,Vector3.UP)

func _ui() -> void:
 var layer:=CanvasLayer.new()
 add_child(layer)
 score_label=Label.new()
 score_label.position=Vector2(28,22)
 score_label.add_theme_font_size_override("font_size",32)
 score_label.add_theme_color_override("font_color",Color(1,0.84,0.2))
 layer.add_child(score_label)
 var help:=Label.new()
 help.position=Vector2(28,66)
 help.text="WASD / стрелки — управление    •    Собирай монетки!"
 help.add_theme_font_size_override("font_size",18)
 help.add_theme_color_override("font_color",Color(0.94,0.97,1))
 layer.add_child(help)
 _score()

func _score() -> void:
 score_label.text="МОНЕТЫ: %d" % score

func _spawn_coin() -> void:
 var coin:=Node3D.new()
 coin.position=Vector3(rng.randf_range(-11.5,11.5),0.48,rng.randf_range(-11.5,11.5))
 if car and coin.position.distance_to(car.position)<3.0:
  coin.position.x=clampf(coin.position.x+5,-11.5,11.5)
 var disc:=MeshInstance3D.new()
 var cyl:=CylinderMesh.new()
 cyl.top_radius=0.43
 cyl.bottom_radius=0.43
 cyl.height=0.13
 disc.mesh=cyl
 disc.rotation_degrees.x=90
 var gold:=StandardMaterial3D.new()
 gold.albedo_color=Color(1,0.72,0.08)
 gold.metallic=0.7
 gold.roughness=0.22
 gold.emission_enabled=true
 gold.emission=Color(0.5,0.25,0.01)
 disc.material_override=gold
 coin.add_child(disc)
 var center:=MeshInstance3D.new()
 var torus:=TorusMesh.new()
 torus.inner_radius=0.23
 torus.outer_radius=0.29
 center.mesh=torus
 center.rotation_degrees.x=90
 var tm:=StandardMaterial3D.new()
 tm.albedo_color=Color(1,0.9,0.35)
 center.material_override=tm
 coin.add_child(center)
 add_child(coin)
 coins.append(coin)

func _process(delta: float) -> void:
 var d:=Vector3(Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left"),0,Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")).normalized()
 velocity=velocity.move_toward(d*SPEED,24*delta)
 car.position+=velocity*delta
 car.position.x=clampf(car.position.x,-12.5,12.5)
 car.position.z=clampf(car.position.z,-12.5,12.5)
 if d.length()>0.05:
  car.rotation.y=lerp_angle(car.rotation.y,atan2(-d.x,-d.z),minf(1,delta*10))
 for coin in coins.duplicate():
  if is_instance_valid(coin):
   coin.rotate_y(delta*2.5)
   if Vector2(car.position.x,car.position.z).distance_to(Vector2(coin.position.x,coin.position.z))<1.15:
    coins.erase(coin)
    coin.queue_free()
    score+=1
    _score()
    _spawn_coin()
 _follow_camera()
