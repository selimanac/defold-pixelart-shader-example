local const           = {}

const.CAMERA_ID       = "/camera#camera"
const.DISPLAY_WIDTH   = sys.get_config_number("display.width")
const.DISPLAY_HEIGHT  = sys.get_config_number("display.height")

--  Pixel-art post process settings
const.PIXEL_SETTINGS  = {
	pixel_size = 2,
	normal_edge_coefficient = 0.03,
	depth_edge_coefficient = 0.35,
}

-- Light orthographic projection settings for shadow
-- Values are per-scene dependent and must be tweaked accordingly.
const.SHADOW_SETTINGS = {
	projection_width  = 12,
	projection_height = 12,
	projection_near   = -220,
	projection_far    = 220,
	depth_bias        = 0.0002, -- Usually it is 0.00002
	shadow_opacity    = 0.4  -- Shadow opacity
}

const.LIGHT_SETTINGS  = {
	source = '/light_source',
	target = '/light_target',
	diffuse_light_color = vmath.vector3(0.5), -- Diffuse light color
}


return const
