shader_type spatial;

uniform bool Show_True_Color ;

uniform sampler2D Carte : source_color;
uniform sampler2D Carte_Path : source_color;

uniform float offset :hint_range(-1.0, 1.0, 0.1);
uniform float fade :hint_range(0.0, 1.0, 0.1);


uniform vec3 White_Flat : source_color = vec3(0.02, 0.45, 0.8);
uniform vec3 White_Slope : source_color = vec3(0.02, 0.45, 0.8);


uniform vec3 Black_Flat : source_color = vec3(0.02, 0.45, 0.8);
uniform vec3 Black_Slope : source_color = vec3(0.02, 0.45, 0.8);
uniform vec3 Black_Track : source_color = vec3(0.02, 0.45, 0.8);

uniform vec3 Red_Flat : source_color = vec3(0.02, 0.45, 0.8);
uniform vec3 Red_Slope : source_color = vec3(0.02, 0.45, 0.8);
uniform vec3 Red_Track : source_color = vec3(0.02, 0.45, 0.8);


uniform vec3 Green_Flat : source_color = vec3(0.02, 0.45, 0.8);
uniform vec3 Green_Slope : source_color = vec3(0.02, 0.45, 0.8);
uniform vec3 Green_Track : source_color = vec3(0.02, 0.45, 0.8);

uniform vec3 Blue_Flat : source_color = vec3(0.02, 0.45, 0.8);
uniform vec3 Blue_Slope : source_color = vec3(0.02, 0.45, 0.8);
uniform vec3 Blue_Track : source_color = vec3(0.02, 0.45, 0.8);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 WORLD_NORMAL = (INV_VIEW_MATRIX * vec4(NORMAL.xyz, 0.0)).xyz;
	float N = dot(WORLD_NORMAL,vec3(0,1,0));
	
	float truc1 = (offset + fade);
	float truc2 = (fade - offset);
	
	N = smoothstep(truc2,truc1,N);
	
	vec3 Tex_Loded = textureLod(Carte,UV,1.0).rgb;
	
	float Only_Black = 0.0;
	if (Tex_Loded == vec3(0,0,0) ){
		Only_Black = 1.0;
	}
	
	Only_Black = 1.0 - (Tex_Loded.r + Tex_Loded.g + Tex_Loded.b);
	Only_Black = clamp(Only_Black,0,1);
	
	
	
	float Only_White = 0.0;
	if (Tex_Loded == vec3(1,1,1) ){
		Only_White = 1.0;
	}
	
	vec3 Red_Track_Map = ((texture(Carte_Path,UV).rgb * Red_Track) * Tex_Loded.r);
	vec3 Green_Track_Map = ((texture(Carte_Path,UV).rgb * Green_Track) * Tex_Loded.g);
	vec3 Blue_Track_Map = ((texture(Carte_Path,UV).rgb * Blue_Track) * Tex_Loded.b);
	vec3 Black_Track_Map = ((texture(Carte_Path,UV).rgb * Black_Track) * Only_Black);
	
	vec3 g = Red_Track_Map + Green_Track_Map + Blue_Track_Map + Black_Track_Map;
	
	float all_track = texture(Carte_Path,UV).r;
	all_track = clamp(all_track,0,1);
	
	float anti_all_track = (1.0 - all_track);
	
	//vec3 Black_Map = Only_Black * Black_Flat;
	vec3 White_Map = Only_White * mix(White_Slope,White_Flat,N);
	vec3 Black_Map = Only_Black * mix(Black_Slope,Black_Flat,N);
	vec3 Red_Map = mix(Red_Slope,Red_Flat,N) * Tex_Loded.r;
	vec3 Green_Map = mix(Green_Slope,Green_Flat,N) * Tex_Loded.g;
	vec3 Blue_Map = mix(Blue_Slope,Blue_Flat,N) * Tex_Loded.b;
	
	
	
	ALBEDO = clamp((Black_Map + Red_Map + Green_Map + Blue_Map) - vec3(all_track),0,1) + g;
	if (Show_True_Color == true) {
		
		vec3 final = clamp(Tex_Loded - vec3(all_track),0,1);
		final += g;
		
		//ALBEDO = Tex_Loded;
		ALBEDO = final;
	}
	
	//ALBEDO = texture(Carte,UV).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
