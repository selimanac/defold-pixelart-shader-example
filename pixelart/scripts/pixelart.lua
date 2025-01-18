local pixelart                 = {}

local DISPLAY_WIDTH            = sys.get_config_number("display.width")
local DISPLAY_HEIGHT           = sys.get_config_number("display.height")

pixelart.render_shadows        = true
pixelart.ambient_light         = vmath.vector4(0.5)

---Default Pixel-art shader constants
local settings                 = {
	pixel_size = vmath.vector4(3),
	normal_edge_coefficient = vmath.vector4(0.035),
	depth_edge_coefficient = vmath.vector4(0.3),
}

---Post Process targets
pixelart.POST_PROCESS          = {
	PIXELATE = '/pixelart_post_process#pixelate_pass',
	RENDER = '/pixelart_post_process#render_pixelated_pass'
}

---Light/Shadow orthographic projection settings. Values are per-scene dependent and must be tweaked accordingly.
pixelart.light_shadow_settings = {
	projection_width  = 12,
	projection_height = 12,
	projection_near   = -20,
	projection_far    = 20,
	depth_bias        = vmath.vector4(0.00002), -- Usually it is 0.00002
	shadow_opacity    = vmath.vector4(0.3),  -- Shadow opacity
}

---Lights
---Light bias matrix
local BIAS_MATRIX              = vmath.matrix4()
BIAS_MATRIX.c0                 = vmath.vector4(0.5, 0.0, 0.0, 0.0)
BIAS_MATRIX.c1                 = vmath.vector4(0.0, 0.5, 0.0, 0.0)
BIAS_MATRIX.c2                 = vmath.vector4(0.0, 0.0, 0.5, 0.0)
BIAS_MATRIX.c3                 = vmath.vector4(0.5, 0.5, 0.5, 1.0)

local light_source_position    = vmath.vector3()
local light_target_position    = vmath.vector3()
local VECTOR_UP                = vmath.vector3(0, 1, 0)
--local inv_light             = vmath.matrix4()
pixelart.light_projection      = vmath.matrix4()
pixelart.light_transform       = vmath.matrix4()
pixelart.mtx_light             = vmath.matrix4()
pixelart.light                 = vmath.vector4()


---Set light matrix
local function set_light_matrix()
	pixelart.mtx_light = BIAS_MATRIX * pixelart.light_projection * pixelart.light_transform
end

---Set light projection
local function set_light_projection()
	pixelart.light_projection = vmath.matrix4_orthographic(-pixelart.light_shadow_settings.projection_width, pixelart.light_shadow_settings.projection_width, -pixelart.light_shadow_settings.projection_height, pixelart.light_shadow_settings.projection_height,
		pixelart.light_shadow_settings.projection_near, pixelart.light_shadow_settings.projection_far)
end

---Set light transform
local function set_light_transform()
	pixelart.light_transform = vmath.matrix4_look_at(light_source_position, light_target_position, VECTOR_UP)
end

---Set Pixel-art resolution for post-processing shader
---@param pixel_size number Pixel size
function pixelart.set_resolution(pixel_size)
	local res = { w = DISPLAY_WIDTH / pixel_size, h = DISPLAY_HEIGHT / pixel_size }
	local result = vmath.vector4(res.w, res.h, 1 / res.w, 1 / res.h)

	go.set(pixelart.POST_PROCESS.PIXELATE, 'resolution', result)
	go.set(pixelart.POST_PROCESS.RENDER, 'resolution', result)
end

-- Light orthographic projection settings for shadow. Values are per-scene dependant and must be tweaked accordingly.
---@class ShadowSettings
---@field projection_width number Shadow projection width
---@field projection_height number Shadow projection height
---@field projection_near number Shadow projection near plane
---@field projection_far number Shadow projection far plane
---@field depth_bias? number The 'depth_bias' value is per-scene dependant and must be tweaked ccordingly. It is needed to avoid shadow acne, which is basically a  precision issue.
---@field shadow_opacity? number  Shadow opacity

-- Light settings
---@class LightSettings
---@field source string Light source URL.
---@field target string Light target URL.
---@field diffuse_light_color? vector4 Diffuse light color.

---Pixel-art post-process initial setup
---@param pixel_settings table Table of pixel-art post-process settings
---@param light_settings? LightSettings Light source and target URLs.
---@param shadow_settings? ShadowSettings Table of shadow post-process settings
function pixelart.init(pixel_settings, light_settings, shadow_settings)
	assert(pixel_settings, "You must provide pixel_settings")

	if light_settings ~= nil then
		assert(light_settings.source, "You must provide 'light_settings.source'")
		assert(light_settings.target, "You must provide 'light_settings.target'")

		-- Light source positions
		light_source_position = go.get_position(light_settings.source)
		light_target_position = go.get_position(light_settings.target)

		pixelart.light.x = light_source_position.x
		pixelart.light.y = light_source_position.y
		pixelart.light.z = light_source_position.z
		pixelart.light.w = 0

		if light_settings.diffuse_light_color ~= nil then
			pixelart.ambient_light.x = light_settings.diffuse_light_color.x
			pixelart.ambient_light.y = light_settings.diffuse_light_color.y
			pixelart.ambient_light.z = light_settings.diffuse_light_color.z
		end
	end

	if shadow_settings then
		pixelart.render_shadows = true
		assert(light_settings, "You must provide 'light_settings'")

		if pixelart.render_shadows then
			assert(shadow_settings, "You must provide 'shadow_settings'")
			assert(shadow_settings.projection_width, "You must provide 'shadow_settings.projection_width'")
			assert(shadow_settings.projection_height, "You must provide 'shadow_settings.projection_height'")
			assert(shadow_settings.projection_near, "You must provide 'shadow_settings.projection_near'")
			assert(shadow_settings.projection_far, "You must provide 'shadow_settings.projection_far'")


			pixelart.light_shadow_settings.projection_width = shadow_settings.projection_width
			pixelart.light_shadow_settings.projection_height = shadow_settings.projection_height
			pixelart.light_shadow_settings.projection_near = shadow_settings.projection_near
			pixelart.light_shadow_settings.projection_far = shadow_settings.projection_far

			if shadow_settings.depth_bias then
				pixelart.light_shadow_settings.depth_bias = vmath.vector4(shadow_settings.depth_bias)
			end


			if shadow_settings.shadow_opacity then
				pixelart.light_shadow_settings.shadow_opacity = vmath.vector4(shadow_settings.shadow_opacity)
			end

			-- Setup light
			set_light_transform()
			set_light_projection()
			set_light_matrix()
		end
	elseif shadow_settings == nil then
		pixelart.render_shadows = false
	end

	-- Effect settings
	settings.pixel_size = vmath.vector4(pixel_settings.pixel_size)
	settings.normal_edge_coefficient = vmath.vector4(pixel_settings.normal_edge_coefficient)
	settings.depth_edge_coefficient = vmath.vector4(pixel_settings.depth_edge_coefficient)

	-- Set default pixel-art values
	pixelart.set_resolution(settings.pixel_size.x)
	go.set(pixelart.POST_PROCESS.RENDER, 'normal_edge_coefficient', settings.normal_edge_coefficient)
	go.set(pixelart.POST_PROCESS.RENDER, 'depth_edge_coefficient', settings.depth_edge_coefficient)
end

return pixelart
