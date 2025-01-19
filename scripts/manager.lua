local pixelart    = require("pixelart.scripts.pixelart")
local const       = require("scripts.const")

local manager     = {}

local camera_zoom = 0

local function window_resized(self, event, data)
	if event == window.WINDOW_EVENT_RESIZED then
		-- TODO Might require scale factor : https://github.com/britzl/defold-orthographic?tab=readme-ov-file#cameraset_window_scaling_factorscaling_factor
		local new_camera_zoom = math.floor(math.max(data.width / const.DISPLAY_WIDTH, data.height / const.DISPLAY_HEIGHT) * camera_zoom)

		go.set(const.CAMERA_ID, "orthographic_zoom", new_camera_zoom)
	end
end

function manager.init()
	-- Init pixel-art post-process
	-- pixelart.init(const.PIXEL_SETTINGS) --without shadows
	pixelart.init(const.PIXEL_SETTINGS, const.LIGHT_SETTINGS, const.SHADOW_SETTINGS)


	if go.exists(const.CAMERA_ID) then
		camera_zoom = go.get(const.CAMERA_ID, "orthographic_zoom")
		-- Window resize listener
		window.set_listener(window_resized)
	end

	--  Basic anims
	for i = 1, 3 do
		go.animate('/coin' .. i, 'position.y', go.PLAYBACK_LOOP_PINGPONG, 1.5, go.EASING_OUTBACK, 0.5)
		go.animate('/coin' .. i, 'euler.y', go.PLAYBACK_LOOP_FORWARD, 270, go.EASING_LINEAR, 1.5)
	end
	go.animate('/gem', 'position.y', go.PLAYBACK_LOOP_PINGPONG, 10.5, go.EASING_OUTBACK, 0.7)
	go.animate('/bee', 'position.y', go.PLAYBACK_LOOP_PINGPONG, 3.4, go.EASING_INOUTQUAD, 2.5)

	go.animate('/slime', 'scale.x', go.PLAYBACK_LOOP_PINGPONG, 2.8, go.EASING_INQUAD, 1.2)
	go.animate('/slime', 'scale.y', go.PLAYBACK_LOOP_PINGPONG, 3.0, go.EASING_INOUTQUAD, 0.5)
end

return manager
