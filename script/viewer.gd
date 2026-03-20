extends Node3D

@onready var camera = $CameraPivot/Camera3D
@onready var ray = $CameraPivot/Camera3D/RayCast3D
@onready var progress_circle = $UI/ProgressCircle
@onready var info_panel = $UI/Panel

var mouse_sensitivity := 0.003
var yaw := 0.0
var pitch := 0.0
var focus_time := 2.0
var look_timer := 0.0
var current_poi = null
var last_opened_poi = null  # точка которую уже открыли — игнорируем
var panel_open := false
var use_gyro := false
var prev_alpha := -1.0
var prev_beta := -1.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	progress_circle.value = 0
	ray.enabled = true
	ray.target_position = Vector3(0, 0, -100)
	info_panel.closed.connect(_on_panel_closed)
	if OS.get_name() == "Web":
		_init_gyro_js()

func _on_panel_closed():
	panel_open = false
	last_opened_poi = current_poi
	look_timer = 0
	progress_circle.value = 0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # захват при закрытии панели

func _init_gyro_js():
	JavaScriptBridge.eval("""
		window._gyro_alpha  = 0;
		window._gyro_beta   = 0;
		window._gyro_active = false;
		function startGyro() {
			if (typeof DeviceOrientationEvent !== 'undefined' &&
				typeof DeviceOrientationEvent.requestPermission === 'function') {
				DeviceOrientationEvent.requestPermission().then(function(state) {
					if (state === 'granted') {
						window.addEventListener('deviceorientation', onOrient);
						window._gyro_active = true;
					}
				});
			} else {
				window.addEventListener('deviceorientation', onOrient);
				window._gyro_active = true;
			}
		}
		function onOrient(e) {
			window._gyro_alpha = e.alpha || 0;
			window._gyro_beta  = e.beta  || 0;
		}
		document.addEventListener('touchstart', function onTouch() {
			startGyro();
			document.removeEventListener('touchstart', onTouch);
		}, { once: true });
	""", true)
	use_gyro = true

func _delta_angle(cur: float, prev: float) -> float:
	var d = cur - prev
	if d > 180.0: d -= 360.0
	elif d < -180.0: d += 360.0
	return d

func _input(event):
	if event is InputEventMouseMotion and not panel_open:
		yaw   -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -1.5, 1.5)

func _process(delta):
	if use_gyro and OS.get_name() == "Web":
		var active = JavaScriptBridge.eval("window._gyro_active", true)
		if active:
			var alpha = float(str(JavaScriptBridge.eval("window._gyro_alpha", true)))
			var beta  = float(str(JavaScriptBridge.eval("window._gyro_beta",  true)))
			if prev_alpha < 0.0:
				prev_alpha = alpha
				prev_beta  = beta
			else:
				if not panel_open:
					yaw   -= deg_to_rad(_delta_angle(alpha, prev_alpha))
					pitch -= deg_to_rad(_delta_angle(beta,  prev_beta))
					pitch  = clamp(pitch, -1.5, 1.5)
				prev_alpha = alpha
				prev_beta  = beta

	$CameraPivot.rotation.y = yaw
	camera.rotation.x = pitch

	if panel_open:
		return

	ray.force_raycast_update()
	var collider = ray.get_collider()

	if collider != null:
		var poi = null
		if collider.has_method("show_info"):
			poi = collider
		elif collider.get_parent() != null and collider.get_parent().has_method("show_info"):
			poi = collider.get_parent()

		if poi != null and poi != last_opened_poi:
			if current_poi != poi:
				look_timer = 0
				current_poi = poi
			look_timer += delta
			progress_circle.value = clamp(look_timer / focus_time * 100, 0, 100)
			if look_timer >= focus_time:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				poi.show_info(info_panel)
				panel_open = true
				look_timer = 0
				progress_circle.value = 0
		else:
			_reset_progress(delta)
	else:
		last_opened_poi = null
		_reset_progress(delta)

func _reset_progress(delta):
	look_timer = max(look_timer - delta * 2, 0)
	progress_circle.value = look_timer / focus_time * 100
	current_poi = null
