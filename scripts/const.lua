local const           = {}

const.CAMERA_ID       = "/camera#camera"
const.DISPLAY_WIDTH   = sys.get_config_number("display.width")
const.DISPLAY_HEIGHT  = sys.get_config_number("display.height")

--  Pixel-art post process settings
const.PIXEL_SETTINGS  = {
	pixel_size = 1,              --Pixel size
	normal_edge_coefficient = 0.03, -- Normal edge for sharpening edges
	depth_edge_coefficient = 0.2, --Depth edge for outline
}

-- Light orthographic projection settings for shadow
-- Values are per-scene dependent and must be tweaked accordingly.
const.SHADOW_SETTINGS = {
	projection_width  = 14,
	projection_height = 14,
	projection_near   = -80,
	projection_far    = 80,
	depth_bias        = 0.002, -- Usually it is 0.00002
	shadow_opacity    = 0.4 -- Shadow opacity
}

const.LIGHT_SETTINGS  = {
	source = '/light_source',
	target = '/light_target',
	diffuse_light_color = vmath.vector3(0.5), -- Diffuse light color
}


return const
