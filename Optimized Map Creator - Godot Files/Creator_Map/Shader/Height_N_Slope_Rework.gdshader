shader_type spatial;

uniform bool Show_True_Color ;

uniform sampler2D Carte : source_color;
uniform sampler2D Carte_Path : source_color;

uniform float offset :hint_range(-1.0, 1.0, 0.1);
uniform float fade :hint_range(0.0, 1.0, 0.1);


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
	
	vec3 Terrain_Carte = textureLod(Carte,UV,6.0).rgb;
	vec3 Path_Carte = textureLod(Carte_Path,UV,6.0).rgb;
	
	vec3 red_paint = mix(Red_Flat,Red_Track,Path_Carte.r);
	vec3 green_paint = mix(Green_Flat,Green_Track,Path_Carte.r);
	vec3 blue_paint = mix(Blue_Flat,Blue_Track,Path_Carte.r);
	vec3 black_paint = mix(Black_Flat,Black_Track,Path_Carte.r);
	
	vec3 red_map = (Terrain_Carte.r * mix(Red_Slope,red_paint,N));
	vec3 green_map = (Terrain_Carte.g * mix(Green_Slope,green_paint,N));
	vec3 blue_map = (Terrain_Carte.b * mix(Blue_Slope,blue_paint,N));
	float bl_value = 1.0 - (Terrain_Carte.r + Terrain_Carte.g + Terrain_Carte.b);
	bl_value = clamp(bl_value,0.0,1.0);
	vec3 black_map = (bl_value * mix(Black_Slope,black_paint,N));
	
	
	
	
	ALBEDO = red_map + green_map + blue_map + black_map;
}
