@tool
extends Node3D
class_name Convex_Creator


func Liste_Epuration_Les_Point_Proches(Liste : PackedVector3Array , Max_Size : int , Point : Vector3):
	
	var New_Liste = Liste.duplicate()
	
	var L = PackedVector3Array()
	L.resize(Liste.size())
	L.fill(Vector3(0,1000000000000,0))

	for i in range (0,New_Liste.size()):
		var distance = Point.distance_to(New_Liste[i])
		
		var combien = 0
		for a in Liste.size():
			var distance_of_other = Point.distance_to(Liste[a])
			if distance > distance_of_other:
				combien += 1

		L[combien] = Liste[i]

	L.resize(Max_Size)
	
	if Liste.size() < Max_Size:
		L.resize(Liste.size())
	
	return L

func Liste_Epuration_Supprimer_les_point_de_mauvaise_orientation(Liste : PackedVector3Array , Side  , Start_Point_Position : Vector3 , End_pOint_Position : Vector3 ):
	var L = PackedVector3Array()
	
	for i in Liste.size():
		var Point_Position = Liste[i]
		
		
		var Dir_S_to_End = Start_Point_Position.direction_to(End_pOint_Position)
		var Dir_P_to_End = Point_Position.direction_to(End_pOint_Position)
		
		var X_value_dir = Ant_Clock(Dir_S_to_End)
		
		var value = X_value_dir.dot(Dir_P_to_End)
		
		if value >= 0:
			value = 1
		else :
			value = -1
			
		
		if Side == null or value == Side:
			L.append(Liste[i])
			
	
	return L

func Liste_Epuration_Supprimer_les_mauvais_angle(Liste : PackedVector3Array , Max_Angle : float , Low_Angle : float ,Start_Point_Position : Vector3 , End_pOint_Position : Vector3):
	var L = PackedVector3Array()
	
	for i in Liste.size():
		var Point_Position = Liste[i]

		var Dir_S_to_End = Start_Point_Position.direction_to(End_pOint_Position)
		var Dir_P_to_End = Point_Position.direction_to(End_pOint_Position)
		
		var value = Dir_S_to_End.dot(Dir_P_to_End)
		
		if (value < Max_Angle) and (value > Low_Angle):
			L.append(Point_Position)
			
	return L
	
func Orientation_du_premier_point(Point : Vector3, Start_Point_Position : Vector3 , End_pOint_Position : Vector3 ):
	var Point_Position = Point
		
		
	var Dir_S_to_End = Start_Point_Position.direction_to(End_pOint_Position)
	var Dir_P_to_End = Point_Position.direction_to(End_pOint_Position)
		
	var X_value_dir = Ant_Clock(Dir_S_to_End)
		
	var value = X_value_dir.dot(Dir_P_to_End)
		
	if value >= 0:
		value = 1
	else :
		value = -1
	
	return value

func Liste_Epuration_Supprimer_Point_Deja_Utilisee(Liste : PackedVector3Array , Liste_a_retirer : PackedVector3Array):
	var L = PackedVector3Array()
	
	for i in Liste.size():
		var already_use = false
		for e in Liste_a_retirer.size():
			if Liste[i] == Liste_a_retirer[e]:
				already_use = true
				
		
		if not already_use:
			L.append(Liste[i])
			
	return L

func Liste_Epuration_Doit_Etre_plus_proche_que_le_precedent(Liste : PackedVector3Array ,Point : Vector3, End_pOint_Position : Vector3 ):
	var L = PackedVector3Array()
	
	var distance_original = Point.distance_to(End_pOint_Position)
	
	for i in Liste.size():
		var distance = Liste[i].distance_to(End_pOint_Position)
		
		if distance < distance_original:
			L.append(Liste[i])
			
	return L

func Finish_the_Job(Liste : PackedVector3Array , End_pOint_Position : Vector3):
	var L = Liste.duplicate()
	
	if L[L.size() - 1] != End_pOint_Position:
		L.append(End_pOint_Position)
		
	return L

func Ant_Clock(this : Vector3):
	return Vector3(-this.z ,this.y, this.x)

func Creation_of_Convex_Hull(List : PackedVector3Array):
	var Convex_List = PackedVector3Array()
	
	var Best_low_z = 0
	var First_child = 0
	var Save_First = Vector3.ZERO
	
	for i in List.size() :
		if List[i].z > Best_low_z:
			First_child = i
			Best_low_z = List[i].z
	
	
	var Selected_Pos = List[First_child]
	Save_First = List[First_child]
	var Last_Dir = Vector3.RIGHT
	
	Convex_List.append(List[First_child])
	
	for i in List.size():
		var chosen_number = Convex_Action(List,Selected_Pos,Last_Dir)
		
		
		
		Selected_Pos = List[chosen_number[0]]
		Last_Dir = chosen_number[1]
		
		if Selected_Pos == Convex_List[0]:
			break
		
		Convex_List.append(Selected_Pos)
		List.remove_at(chosen_number[0])
		
		
	
	
	
	
	
	if Convex_List[Convex_List.size() -1] != Convex_List[0]:
		Convex_List.append(Convex_List[0])
	
	return Convex_List

func Convex_Action(List : Array,Selected_Pos : Vector3 ,Last_Dir : Vector3):
	
	var best_angle = -1
	var best_angle_number = null
	var best_angle_dir = Vector3.ZERO
	
	for i in List.size():
		var dis = Selected_Pos.distance_to(List[i])
		var dir_to_next = Selected_Pos.direction_to(List[i])
		var dir  = Last_Dir.signed_angle_to(-dir_to_next , Vector3.DOWN)
		dir = rad_to_deg(dir)
		if dir < 0:  
			dir += 360
		
		
		
		
		
		if dir > best_angle and not dis == 0 and dir_to_next != -Last_Dir and dir <= 180:
			best_angle = dir
			best_angle_number = i
			best_angle_dir = dir_to_next
		#prod = Dir_1.signed_angle_to(-Dir_2 , Vector3.UP)
	
	var Ar = [best_angle_number , best_angle_dir]
	
	return Ar

#func Create_path(List : PackedVector3Array ,Return_The_Path : bool , Red : int ,Green : int ,Blue : int):
	##var Path = Path3D.new()
	#var Path = Road_Path.new()
	#
	#Path.Wide_Red_Road = Red
	#Path.Wide_Green_Road = Green
	#Path.Wide_Blue_Road = Blue
	#
	#var cur = Curve3D.new()
	#Path.name = str("Path_Convex")
	#Path.curve = cur
	#
	#if Return_The_Path == false:
		##get_tree().get_root().get_child(0).add_child(Path)
		#
		#get_tree().edited_scene_root.add_child(Path)
		#
		#Path.owner = get_tree().edited_scene_root
	#
	#for i in List.size():
		#Path.curve.add_point(List[i])
		#
	#if Return_The_Path:
		#return Path

func Complexify_List(List : PackedVector3Array , Distance_Min : int , Ecartement : int , Nombre_Iteration : int , One_Side_Only : bool , int_only : bool):
	#print("Before : ",List)
	
	var Point_Added = 0
	
	for i in ((List.size() - 1)):
		
		var iter = (i) + Point_Added
		
		
		
		
		var dis = List[iter].distance_to(List[iter + 1])
		var dir = List[iter].direction_to(List[iter + 1])
		var pos = lerp(List[iter] , List[iter + 1] , 0.5)
		
		var old_pos = List[iter]
		var new_pos = List[iter + 1]
		
		if dis > Distance_Min :
			
			#randomize()
			#var Ec = randf_range(-Ecartement , Ecartement)
			
			for a in range(1,Nombre_Iteration):
				iter = (i) + Point_Added
				var Ratio = float(a) / float(Nombre_Iteration)
				
				
				pos = lerp(old_pos,new_pos,Ratio)
			
			
				randomize()
				var Ec = randf_range(-Ecartement , Ecartement)
				
				if One_Side_Only:
					Ec = absf(Ec)
				
				var dir_x = Ant_Clock(dir) * Ec 
				
				
				
				pos += dir_x
				
				if int_only :
					pos.x = int(pos.x)
					pos.y = int(pos.y)
					pos.z = int(pos.z)
					#print(pos)

				List.insert(iter + 1 ,pos)
				
				Point_Added += 1
	
	#print("After : ",List)
	return List

func Convex_Point_Placement(List : PackedVector3Array , Point_a_rajouter , Nom_Des_List : String ):
	var nody = get_tree().edited_scene_root
	if not Engine.is_editor_hint():
		nody = get_tree().current_scene
	var NodeConvexHull = Node3D.new()
	nody.add_child(NodeConvexHull)
	NodeConvexHull.name = str("Node_",Nom_Des_List)
	
	
	NodeConvexHull.owner = get_tree().edited_scene_root
	for i in List.size():
		var pos = List[i]
		var Convex_Hull_Point_ = null
		if Point_a_rajouter != null:
			Convex_Hull_Point_ = Point_a_rajouter.duplicate()
		
		
		nody.get_node(str("Node_",Nom_Des_List)).add_child(Convex_Hull_Point_)
		Convex_Hull_Point_.position = pos
		Convex_Hull_Point_.name = str(Nom_Des_List,"_Point_")
		Convex_Hull_Point_.owner = get_tree().edited_scene_root

func Create_Shortcut_Point(Path : Path3D , Combien : int , End_Shortcut_offset : int  ,Short_Entry_Name : String , Short_Sorty_Name : String , Entry_Ball , Sorty_Ball ):
	var nody = get_tree().edited_scene_root
	var List_Entry = PackedVector3Array()
	var List_Sorty = PackedVector3Array()
	
	var NodeShort_Entry = Node3D.new()
	var NodeShort_Sorty = Node3D.new()
	
	nody.add_child(NodeShort_Entry)
	nody.add_child(NodeShort_Sorty)
	
	
	NodeShort_Entry.owner = nody
	NodeShort_Sorty.owner = nody
	
	NodeShort_Entry.name = str("Node_",Short_Entry_Name)
	NodeShort_Sorty.name = str("Node_",Short_Sorty_Name)
	
	
	var nombre = int(Path.curve.get_baked_length() / Combien)
	var longueur_du_path = Path.curve.get_baked_length()
	
	for i in Combien - 1:
		
		randomize()
		var rand_end = randf_range(-End_Shortcut_offset , End_Shortcut_offset)
		
		var offset = (i * nombre)
		var offset_end_shortcut = ( (i + 1) * nombre ) + rand_end
		
		
		var Shortcut_ball = Entry_Ball.duplicate()
		nody.get_node(str("Node_",Short_Entry_Name)).add_child(Shortcut_ball)
		Shortcut_ball.name = str("Shotcut_",i)
		var pos = Path.curve.sample_baked(offset)
		Shortcut_ball.position = pos
		List_Entry.append(pos)
		Shortcut_ball.owner = nody
		
		var End_Shortcut_ball = Sorty_Ball.duplicate()
		nody.get_node(str("Node_",Short_Sorty_Name)).add_child(End_Shortcut_ball)
		End_Shortcut_ball.name = str("End_Shorcut_",i)
		var pos1 = Path.curve.sample_baked(offset_end_shortcut)
		End_Shortcut_ball.position = pos1
		List_Sorty.append(pos1)
		End_Shortcut_ball.owner = nody
		
		
	return [List_Entry,List_Sorty]

func Create_List_Of_Remaining_Point(List : Array , Adding : bool , List_a_retirer : Array):
	
	if Adding:
		for i in List_a_retirer.size():
			List.append(List_a_retirer[i])
			
	if not Adding:
		for i in List_a_retirer.size():
			for e in List.size():
				
				if List_a_retirer[i] == List[e]:
					List.remove_at(e)
					break
	
	return List

func Adding_out_of_ring_point(In_Limit : float  , Out_Limit : float , Nombre_Point : int , Width : int , Length : int):
	var List = []
	for i in Nombre_Point :

		
		randomize()
		var x = randf_range(float(Width) * float(In_Limit) , Width * float(1 + Out_Limit))
		randomize()
		var z = randf_range(float(Length) * float(In_Limit) , Length * float(1 + Out_Limit))
		
		randomize()
		
			
		var Pos = Vector3.ZERO
		Pos.x = x 
		Pos.z = z 
		
		#Pos.x =  nx
		#Pos.z =  nz
		
		
		List.append(Pos)
		
	
	return List

func Smooth_the_path(Cuv : Curve3D , Pow : int):
	var Cu = Cuv.duplicate()
	
	for i in range(1,Cu.point_count - 1):
		print("pointttttttttttttttttttt = ",i)
		var dir_one = Cu.get_point_position(i - 1 ).direction_to(Cu.get_point_position(i))
		var dir_two = Cu.get_point_position(i).direction_to(Cu.get_point_position(i + 1))
		
		var prod = (dir_one + dir_two).normalized()
		
		Cu.set_point_in(i,-prod * Pow)
		Cu.set_point_out(i,prod * Pow)
	
	return Cu

func Create_road(P : Path3D,Largeur : float,Colide_layer : int , visibilite : bool):
	var off_ratio = 0
	var PackV = []
	var longueur = P.curve.get_baked_length()
	
	while off_ratio <= 1:
		var Pack_Ajout = []
		var pos = P.curve.sample_baked_with_rotation(off_ratio * longueur,false,false)
		var pos_L = pos.origin + (pos.basis.x * Largeur)
		var pos_R = pos.origin + (-pos.basis.x * Largeur)
		
		Pack_Ajout.append(pos_L)
		Pack_Ajout.append(pos_R)
		
		PackV.append(Pack_Ajout)
		off_ratio += 0.001
		pass
	

	var vertices = PackedVector3Array()
	for i in PackV.size()-1:
		vertices.push_back(PackV[i][0])
		vertices.push_back(PackV[i][1])
		vertices.push_back(PackV[i+1][1])
		
		vertices.push_back(PackV[i][0])
		vertices.push_back(PackV[i+1][1])
		vertices.push_back(PackV[i+1][0])
	
	vertices.push_back(PackV[PackV.size()-1][0])
	vertices.push_back(PackV[PackV.size()-1][1])
	vertices.push_back(PackV[0][1])
	
	vertices.push_back(PackV[PackV.size()-1][0])
	vertices.push_back(PackV[0][1])
	vertices.push_back(PackV[0][0])

	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices

	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var m = MeshInstance3D.new()
	m.mesh = arr_mesh
	add_child(m)
	
	if Engine.is_editor_hint():
		m.owner = get_tree().edited_scene_root
	m.create_trimesh_collision()
	
	m.visible = visibilite
	
	var stat = m.get_child(0)
	
	if stat is StaticBody3D:
		stat.collision_mask = Colide_layer
		stat.collision_layer = Colide_layer
	
	#if Engine.is_editor_hint():
		#m.owner = get_tree().edited_scene_root
	
	pass

func Smooth_the_path_V2(Cuv : Curve3D,Smooth_Range:float):
	var Point_Total = Cuv.point_count
	for u in range(1, Point_Total - 1):
		var before_dis = Cuv.get_point_position(u-1).distance_to(Cuv.get_point_position(u))
		var after_dis = Cuv.get_point_position(u).distance_to(Cuv.get_point_position(u+1))
		var longueur = minf(before_dis, after_dis)/Smooth_Range
		
		var before_dir = Cuv.get_point_position(u-1).direction_to(Cuv.get_point_position(u))
		var after_dir = Cuv.get_point_position(u).direction_to(Cuv.get_point_position(u+1))
		var direction = (before_dir + after_dir).normalized()
		
		Cuv.set_point_out(u,direction * longueur)
		Cuv.set_point_in(u,-direction * longueur)
	
	var before_dis = Cuv.get_point_position(Point_Total - 2).distance_to(Cuv.get_point_position(Point_Total - 1))
	var after_dis = Cuv.get_point_position(0).distance_to(Cuv.get_point_position(1))
	var longueur = minf(before_dis, after_dis)/Smooth_Range
		
	var before_dir = Cuv.get_point_position(Point_Total-2).direction_to(Cuv.get_point_position(Point_Total - 1))
	var after_dir = Cuv.get_point_position(0).direction_to(Cuv.get_point_position(1))
	var direction = (before_dir + after_dir).normalized()
	
	Cuv.set_point_out(0,direction * longueur)
	Cuv.set_point_in(Point_Total-1,-direction * longueur)
	return Cuv
