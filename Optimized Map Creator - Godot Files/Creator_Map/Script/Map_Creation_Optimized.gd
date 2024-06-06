@tool
extends MeshInstance3D

var Altitude = {}
var Temperature = {}
var Atmosphere = {}

@export var Create = false

@export var height = 100
@export var width = 100
@export_enum("None","Side_x","Island") var Fall_Off : int
@export var Fall_Off_Multi = 0.5
@export var Alti_Multi = 1.0
@export var Mesh_Alti_Multi = 25

@export var Wide_Terrain_Multi = 1.0

@export var Fall_out_Entree = 0.8
@export var Fall_out_Sortie = 0.4

@export var f : FastNoiseLite
#@onready var L = Liste_Biome.new()

#@onready var List_2D = [$Code_Couleur/Black_Code,$Code_Couleur/Red_Code,$Code_Couleur/Green_Code,$Code_Couleur/Blue_Code]


@export var Env_Black : int
@export var Env_Red : int
@export var Env_Green : int
@export var Env_Blue : int


@export_global_dir var Lieux_Sauvegarde

var Angle = 0
var Up_Cam = 0
var Point__pivot = Vector3.ZERO


@export var Liste_Prop : Array[PackedScene]
@export var Fill_Grid = 2
@export var Global_Chance_Mode = false
@export_range(0.0,1.0,0.01) var Global_Chance = 0.5

@onready var Carte_Chemin = Image.new()
@onready var Carte_Chemin_2 = Image.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	if not Engine.is_editor_hint():
		Creation_Track()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint() and Create == true:
		Creation_Track()
		Create = false
	pass

func Creation_Track():
	var Pixel_Mult = height/100.0
	
	Preparation_Image()
	Creation_Librairie_Atmosphere()
	var Convex_Path = Path3D.new()
	Convex_Path.curve = Creation_Convex_Path(10,Vector3(height/2,0,width/2) ,10 * Pixel_Mult,40 * Pixel_Mult,Wide_Terrain_Multi,Mesh_Alti_Multi)
	$MeshInstance3D.position = Vector3(height/2 ,0 ,width/2) * Wide_Terrain_Multi
	
	ScriptDeCalculArray.Create_road(Convex_Path,5,1,false)
	ScriptDeCalculArray.Create_road(Convex_Path,10,4,false)
	
	var Table_Environement = Create_Color_Carte(height,width)
	
	for i in 3:
		Adaptation_du_terrain(height,width,2)
	
	Creation_Mesh(height,width)
	
	
		
	add_child(Convex_Path)
	
	if Engine.is_editor_hint():
		Convex_Path.owner = get_tree().edited_scene_root
	
	pass

func Preparation_Image():
	Carte_Chemin = Image.create(height,width,false,Image.FORMAT_BPTC_RGBA)
	Carte_Chemin.decompress()
	
	Carte_Chemin_2 = Image.create(height,width,false,Image.FORMAT_BPTC_RGBA)
	Carte_Chemin_2.decompress()

func Creation_Librairie_Atmosphere():
	Altitude = Create_Carte(height,width,0.005,5,2,0,Fall_Off,Alti_Multi,true)
	Temperature = Create_Carte(height,width,0.001,5,2,1,0,10,false)
	Atmosphere = Create_Carte(height,width,0.001,5,2,0.5,0,1,false)

func Create_Carte(height : int , width : int ,frequence : float, octave : float , lacun : float, smooth : float , type_fade : int , Multiplicateur : float , it_is_alt : bool):
	var GridName = {}
	var Noise_ = FastNoiseLite.new()
	Noise_.frequency = frequence
	Noise_.fractal_octaves = octave
	Noise_.fractal_lacunarity = lacun
	Noise_.fractal_weighted_strength = smooth
	randomize()
	Noise_.seed = randi_range(0,10000)
	
	for x in height:
		for z in width:
			GridName[Vector2(x,z)] = (absf((Noise_.get_noise_2d(x,z) * Multiplicateur)) * clampf(add_Fall_off(Vector2(x,z),height,width,type_fade),0,100))
			#GridName[Vector2(x,z)] = (absf((Noise_.get_noise_2d(x,z) * Alti_Multi)) * clampf(add_Fall_off(Vector2(x,z),height,width,type_fade),0,100))
			#GridName[Vector2(x,z)] = (clampf((Noise_.get_noise_2d(x,z) * Alti_Multi),0,1) * clampf(add_Fall_off(Vector2(x,z),height,width,type_fade),0,100))
			GridName[Vector2(x,z)] = clampf(GridName[Vector2(x,z) ],0,3)
			
			if not it_is_alt:
				GridName[Vector2(x,z)] = clampf(GridName[Vector2(x,z) ],0.1,0.99)
	
	return GridName

func add_Fall_off(position_ : Vector2 , height : int , width : int , type : int):
	if type == 0:
		return 1
	
	if type == 1:
		var x = float(position_.x) / float(height)
		if x < Fall_out_Entree:
			var c = x
			x = inverse_lerp(Fall_out_Sortie,Fall_out_Entree,x) * c
		#else:
			#x = 1
		return x 
	
	if type == 2:
		var x_r = float(position_.x) / float(height - 1)
		var z_r = float(position_.y) / float(width - 1)
		
		var pos = Vector2(x_r,z_r)
		var center = Vector2(0.5,0.5)
			
		var total = 0
		var divisor = 2.0
		#var power = 1

		total = 1 - center.distance_to(pos)
		#total = pow(total,power)
		
		if total < Fall_out_Entree:
			var c = total
			total = inverse_lerp(Fall_out_Sortie,Fall_out_Entree,total) #* c
		else:
			total = 1
		
		return total

func Add_Pack_To_Curve(Pack : PackedVector3Array):
	var C = Curve3D.new()
	
	for i in Pack.size():
		C.add_point(Pack[i],Vector3.ZERO,Vector3.ZERO,i)
		
	return C

func Creation_Convex_Path(nombre_point , Centre : Vector3 , Min_away , Max_away , Wide , Alt_multi):
	var Conv_List_of_point = PackedVector3Array()
	
	for i in nombre_point:
		var side_x = Side()
		var side_z = Side()
		
		var pos = Centre
		randomize()
		pos.x = randi_range(Min_away , Max_away) * side_x
		pos.z = randi_range(Min_away , Max_away) * side_z
		
		pos.x = int(pos.x * Wide)
		pos.y = int(pos.y * Wide)
		pos.z = int(pos.z * Wide)
		
		var good_pos = Vector3()
		good_pos.x = int(pos.x + (Centre.x * Wide))
		good_pos.y = int(pos.y + (Centre.y * Wide))
		good_pos.z = int(pos.z + (Centre.z * Wide))
		
		Conv_List_of_point.append(good_pos)
	
	Conv_List_of_point = ScriptDeCalculArray.Creation_of_Convex_Hull(Conv_List_of_point)
	
	Conv_List_of_point = ScriptDeCalculArray.Complexify_List(Conv_List_of_point,10,1,3,false,true)
	
	Conv_List_of_point = Adapt_Point_to_altitude(Conv_List_of_point,Alt_multi,Wide)
	
	
	var C = Add_Pack_To_Curve(Conv_List_of_point)
	C.up_vector_enabled = false
	
	C = ScriptDeCalculArray.Smooth_the_path_V2(C,2.0)
	
	return C

func Side():
	randomize()
	var chance = randi_range(0,1)
	if chance > 0:
		return 1
	else:
		return -1

func Adapt_Point_to_altitude(Pack_to_adapt : PackedVector3Array, Alti_M : float , W : float):
	print("launched")
	var New_Pack = PackedVector3Array()
	
	for i in Pack_to_adapt.size():
		var pos = Vector2(int(Pack_to_adapt[i].x),int(Pack_to_adapt[i].z))
		pos.x /= W#ide_Terrain_Multi
		pos.y /= W#ide_Terrain_Multi
		
		pos.x = int(pos.x)
		pos.y = int(pos.y)
		
		var found = Altitude[pos] * Alti_M
		
		var new_pos = Vector3()
		new_pos.x = int(pos.x * W)#ide_Terrain_Multi
		new_pos.y = found
		new_pos.z = int(pos.y * W)#ide_Terrain_Multi
		
		New_Pack.append(new_pos)
	
	return New_Pack

func Creation_Mesh(height : int , width : int ):
	var Arr = PackedVector3Array()
	var Uv_Arr = PackedVector2Array()

	
	for x in height - 1:
		for z in width - 1:
			var Alt_Mult = Mesh_Alti_Multi
			var Wide_Multi = Wide_Terrain_Multi
			
			
			
			Arr.push_back(Vector3(x * Wide_Multi,Altitude[Vector2(x,z)] * Alt_Mult,z* Wide_Multi))
			Uv_Arr.push_back(Vector2(float(x)/ float(height)  , float(z)/ float(width)))
			
			Arr.push_back(Vector3((x + 1) * Wide_Multi,Altitude[Vector2(x +1,z)] * Alt_Mult,z * Wide_Multi))
			Uv_Arr.push_back(Vector2(float(x + 1)/ float(height)  , float(z)/ float(width)))
			
			Arr.push_back(Vector3(x* Wide_Multi,Altitude[Vector2(x,z + 1)] * Alt_Mult,(z + 1)* Wide_Multi))
			Uv_Arr.push_back(Vector2(float(x)/ float(height)  , float(z + 1)/ float(width)))
			
			#########################
			Arr.push_back(Vector3(x* Wide_Multi,Altitude[Vector2(x,z + 1)] * Alt_Mult,(z + 1) * Wide_Multi))
			Uv_Arr.push_back(Vector2(float(x)/ float(height)  , float(z + 1)/ float(width)))
			
			Arr.push_back(Vector3((x + 1)* Wide_Multi,Altitude[Vector2(x + 1,z)] * Alt_Mult,z* Wide_Multi))
			Uv_Arr.push_back(Vector2(float(x + 1)/ float(height)  , float(z)/ float(width)))
			
			Arr.push_back(Vector3((x + 1) * Wide_Multi,Altitude[Vector2(x + 1,z + 1)] * Alt_Mult,(z + 1)* Wide_Multi))
			Uv_Arr.push_back(Vector2(float(x + 1)/ float(height)  , float(z + 1)/ float(width)))
			
			
			
			
	
	
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = Arr
	arrays[Mesh.ARRAY_TEX_UV] = Uv_Arr
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	mesh = arr_mesh

	var Surf = SurfaceTool.new()
	Surf.create_from(mesh,0)
	
	Surf.generate_tangents()
	Surf.generate_normals()
	
	mesh = Surf.commit()
	create_trimesh_collision()
	
	pass

func Create_Color_Carte(height : int , width : int):
	print("Begin_Color")
	var Carte = Image.create(height,width,false,Image.FORMAT_BPTC_RGBA)
	Carte.decompress()
	
	#var Carte_Chemin = Image.create(height,width,false,Image.FORMAT_BPTC_RGBA)
	#Carte_Chemin.decompress()
	
	
	var Ray = RayCast3D.new()
	Ray.exclude_parent = false
	Ray.target_position = Vector3(0,-1000,0)
	add_child(Ray)
	
	var Ray_3 = RayCast3D.new()
	Ray_3.collision_mask = 4
	Ray_3.exclude_parent = false
	Ray_3.target_position = Vector3(0,-1000,0)
	add_child(Ray_3)
	
	var Table_Environement = {}
	
	for x in height:
		for z in width:
			var Couleur_a_rajouter = Color.BLACK
			var pos = Vector2(x,z)
			
			var alt = Altitude[pos]
			var atm = Atmosphere[pos]
			var tem = Temperature[pos]
			
			
			if beetween(alt,0,0.2):
				Couleur_a_rajouter = Color.BLACK
			
			elif beetween(alt,0.2,0.5):
				if beetween(atm,0.3,1.0):
					Couleur_a_rajouter = Color.RED
				else:
					Couleur_a_rajouter = Color.BLACK
			
			elif  beetween(alt,0.5,1):
				if beetween(atm,0.3,1.0):
					Couleur_a_rajouter = Color.GREEN
				else:
					Couleur_a_rajouter = Color.BLACK
					
			elif  beetween(alt,1,3):
				if beetween(atm,0.5,1.0):
					Couleur_a_rajouter = Color.BLUE
				else:
					Couleur_a_rajouter = Color.BLUE
			###############
			Table_Environement[Vector2(x,z)] = Trad_Couleur_for_Environnement(Couleur_a_rajouter)
			
			var position_du_ray = Vector3(x * Wide_Terrain_Multi ,200,z * Wide_Terrain_Multi)
			Ray.position = position_du_ray
			Ray.force_raycast_update()
			Ray.force_update_transform()
			
			Ray_3.position = position_du_ray
			Ray_3.force_raycast_update()
			Ray_3.force_update_transform()
			
			Carte.set_pixelv(pos,Couleur_a_rajouter)
			
			if Ray.is_colliding()  and alt > 0: #and not beetween(alt,0,0.1)
				#print("touch")
				var new_pos = Vector2()
				new_pos.x = int(pos.x )#/ Wide_Terrain_Multi)
				new_pos.y = int(pos.y )#/ Wide_Terrain_Multi)
				Carte_Chemin.set_pixelv(new_pos,Color.WHITE)
				Altitude[pos] = float(Ray.get_collision_point().y) / float(Mesh_Alti_Multi)
				#
				Table_Environement[Vector2(new_pos.x,new_pos.y)] = Trad_Couleur_for_Environnement(Color.BLUE)
				
			if Ray_3.is_colliding() and alt > 0: #and not beetween(alt,0,0.1)
				#print("touch")
				var new_pos = Vector2()
				new_pos.x = int(pos.x )#/ Wide_Terrain_Multi)
				new_pos.y = int(pos.y )#/ Wide_Terrain_Multi)
				Carte_Chemin_2.set_pixelv(new_pos,Color.WHITE)
				#Altitude[pos] = float(Ray.get_collision_point().y) / float(Mesh_Alti_Multi)
				#
				Table_Environement[Vector2(new_pos.x,new_pos.y)] = Trad_Couleur_for_Environnement(Color.BLUE)
			
			
			#Carte.set_pixelv(pos,Couleur_a_rajouter)
			
	Carte.save_png(Lieux_Sauvegarde + "/Carte.png")
	Carte_Chemin.save_png(Lieux_Sauvegarde + "/Carte_Chemin.png")
	Carte_Chemin_2.save_png(Lieux_Sauvegarde + "/Carte_Chemin_2.png")
	
	var I = ImageTexture.new()
	I.set_image(Carte)
	
	var IC = ImageTexture.new()
	IC.set_image(Carte_Chemin)
	
	
	get_surface_override_material(0).set("shader_parameter/Carte",I)
	get_surface_override_material(0).set("shader_parameter/Carte_Path",IC)
	
	return Table_Environement
	
func beetween(val : float , min_ : float , max_ : float):
	if val >= min_ and val <= max_:
		return true
	else:
		false

func Trad_Couleur_for_Environnement(Couleur : Color):
	if Couleur == Color.BLACK:
		return Env_Black
	elif Couleur == Color.RED:
		return Env_Red
	elif Couleur == Color.GREEN:
		return Env_Green
	elif Couleur == Color.BLUE:
		return Env_Blue

func Adaptation_du_terrain(height : int ,width : int , smooth_square : int):
	var New_Alt = {}
	var Changed_Reference = PackedVector2Array()
	for x in height - 1:
		for y in width - 1:
			var pos = Vector2(x,y)
			var Total_Alt = 0
			var Nombre_T = 0
			
			if  Carte_Chemin_2.get_pixel(pos.x,pos.y) == Color.WHITE: #Carte_Chemin.get_pixel(pos.x,pos.y) == Color.WHITE or
				#print("need_s")
				for xx in range(-(smooth_square/2),smooth_square/2):
					for yy in range(-(smooth_square/2),smooth_square/2):
						var nx = clampf(x + xx , 0 , height - 1)
						var ny = clampf(y + yy , 0 , width - 1)
						var new_pos = Vector2(nx,ny)
						Total_Alt += Altitude[new_pos]
						Nombre_T += 1
				
				Changed_Reference.append(Vector2(x,y))
				New_Alt[Vector2(x,y)] = Total_Alt / float(Nombre_T)
			
			pass
			
	for i in Changed_Reference.size():
		Altitude[Changed_Reference[i]] = New_Alt[Changed_Reference[i]]
