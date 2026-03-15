shader_type canvas_item;
//Based on https://www.youtube.com/watch?v=6ZPOYG9geUQ
uniform float outline_thickness:hint_range(0.0, 20.0, 0.1) = 5.;
uniform float anti_alias_amount = 1.0;
uniform vec4 outline_colour:source_color = vec4(1);

void fragment() {
	if(COLOR.a == 0.){
		//distance around this pixel we'll look for a solid pixel
		float max_dist = outline_thickness + anti_alias_amount;
		int max_pixel_offset = int(ceil(max_dist));
		float closest_visible_pixel_dist = max_dist;
		//Loop through neighbouring pixels to 
		for(int x = -max_pixel_offset; x <= max_pixel_offset; x++){
			for(int y = -max_pixel_offset; y <= max_pixel_offset; y++){
				vec2 offset = vec2(float(x),float(y));
				float dist = length(offset);
				
				//search only the circular neighbourhood
				if(dist > max_dist) continue;
				//check if we're part of the original sprite
				if(texture(TEXTURE,UV + offset*TEXTURE_PIXEL_SIZE).a > 0.){
					closest_visible_pixel_dist = min(closest_visible_pixel_dist,dist);
				}
			}
		}
		//Returns a value from 0 to 1, based on how close closest_visible_pixel is to the two given endpoints
		float alpha = 1.0 - smoothstep(outline_thickness - anti_alias_amount,outline_thickness + anti_alias_amount,closest_visible_pixel_dist);
		COLOR = vec4(outline_colour.rgb,alpha);
	}
}
