--
-- This file contains Volume Widget functions for awesome.
--

-- Initialize
function volumeinit()
    local sd = io.popen("aplay -l | grep \"card\" | grep -c \"Device\"")
    local Device = sd:read("*all")
    sd:close()
    if Device == "1\n" then
        cardid  = 1
        muteChannel = "Speaker"  -- Chanel for adjusting volume
        adjustChannel = "Speaker"  -- Channel to mute
    else
        cardid = 0
        adjustChannel = "PCM" -- Chanel for adjusting volume
        muteChannel = "Master" -- Channel to mute
    end
end
volumeinit()

function volume (mode, widget)
    if mode == "update" then
        volumeinit()
        local fd = io.popen("amixer -c " .. cardid .. " -- sget " .. adjustChannel)
        local fd2 = io.popen("amixer -c " .. cardid .. " -- sget " .. muteChannel)
        local adjustStatus = fd:read("*all")
        local muteStatus = fd2:read("*all")
        fd:close()
        if adjustStatus == "" or muteStatus == "" then
            widget.text = "N/A"
        else
            local volume = string.match(adjustStatus, "(%d?%d?%d)%%")
	     volume = string.format("% 3d", volume)

	    status = string.match(muteStatus, "%[(o[^%]]*)%]")

	    if string.find(status, "on", 1, true) then
	        volume = volume .. "%"
            else
	        volume = volume .. "M"
	    end
	    widget.text = volume
        end
     elseif mode == "up" then
		io.popen("amixer -q -c " .. cardid .. " sset " .. adjustChannel .. " 5%+"):read("*all")
		volume("update", widget)
    elseif mode == "down" then
		io.popen("amixer -q -c " .. cardid .. " sset " .. adjustChannel .. " 5%-"):read("*all")
		volume("update", widget)
    else
		io.popen("amixer -c " .. cardid .. " sset " .. muteChannel .. " toggle"):read("*all")
		volume("update", widget)
     end
end
