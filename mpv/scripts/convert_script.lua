-- README:
-- original version by Zehkul https://gist.github.com/Zehkul/25ea7ae77b30af959be0
-- convert script for mpv, just throw it into ~/.mpv/lua/
-- needs: yad, libnotify and at least mpv 0.4
-- press alt + w to make a webm
-- press alt + g to make a gif
-- press alt + x to make a x264 encoded mkv

local msg = require 'mp.msg'
local opt = require 'mp.options'
local mputils = require 'mp.utils'

-- default options, convert_script.conf is read
local options = {
    bitrate_multiplier = 0.975,			-- to make sure the file won’t go over the target file size, set it to 1 if you don’t care
    output_directory = '"$HOME"',
    use_pwd_instead = false,			-- overrides output_directory
    threads = 4,
}

read_options(options, "convert_script_webm")
read_options(options, "convert_script_gif")
read_options(options, "convert_script_x264")

-----------------
-- Main script --
-----------------

function convert_script_hotkey_call_webm ()
    
    set_mouse_area = true
    width = mp.get_property("dwidth")
    height = mp.get_property("dheight")
    mp.set_mouse_area(0, 0, width, height, "draw_rectangle")
    mp.set_osd_ass(width, height, "")
    
    if timepos1 then
        
	timepos2 = mp.get_property("time-pos")
	timepos2_humanreadable = mp.get_property_osd("time-pos")
	
	if tonumber(timepos1) > tonumber(timepos2) then
            
            length = timepos1-timepos2
            start = timepos2
	    start_humanreadable = timepos2_humanreadable
	    end_humanreadable = timepos1_humanreadable
	    msg.info("End frame set")
	    
	elseif tonumber(timepos2) > tonumber(timepos1) then
	    
	    length = timepos2-timepos1
	    start = timepos1
	    start_humanreadable = timepos1_humanreadable
	    end_humanreadable = timepos2_humanreadable
	    msg.info("End frame set")
	
	else
	
	    msg.error("Both frames are the same, ignoring the second one")
	    mp.osd_message("Both frames are the same, ignoring the second one")
	    timepos2 = nil
	    return
	       
	end
	
	timepos1 = nil
	mp.enable_key_bindings("draw_rectangle")
	call_gui_webm()
	
    else
        
	timepos1 = mp.get_property("time-pos")
	timepos1_humanreadable = mp.get_property_osd("time-pos")
        msg.info("Start frame set")
        mp.osd_message("Start frame set")
    
    end

end

function convert_script_hotkey_call_gif ()
    
    set_mouse_area = true
    width = mp.get_property("dwidth")
    height = mp.get_property("dheight")
    mp.set_mouse_area(0, 0, width, height, "draw_rectangle")
    mp.set_osd_ass(width, height, "")
    
    if timepos1 then
        
    timepos2 = mp.get_property("time-pos")
    timepos2_humanreadable = mp.get_property_osd("time-pos")
    
    if tonumber(timepos1) > tonumber(timepos2) then
            
            length = timepos1-timepos2
            start = timepos2
        start_humanreadable = timepos2_humanreadable
        end_humanreadable = timepos1_humanreadable
        msg.info("End frame set")
        
    elseif tonumber(timepos2) > tonumber(timepos1) then
        
        length = timepos2-timepos1
        start = timepos1
        start_humanreadable = timepos1_humanreadable
        end_humanreadable = timepos2_humanreadable
        msg.info("End frame set")
    
    else
    
        msg.error("Both frames are the same, ignoring the second one")
        mp.osd_message("Both frames are the same, ignoring the second one")
        timepos2 = nil
        return
           
    end
    
    timepos1 = nil
    mp.enable_key_bindings("draw_rectangle")
    call_gui_gif()
    
    else
        
    timepos1 = mp.get_property("time-pos")
    timepos1_humanreadable = mp.get_property_osd("time-pos")
        msg.info("Start frame set")
        mp.osd_message("Start frame set")
    
    end

end

function convert_script_hotkey_call_x264 ()
    
    set_mouse_area = true
    width = mp.get_property("dwidth")
    height = mp.get_property("dheight")
    mp.set_mouse_area(0, 0, width, height, "draw_rectangle")
    mp.set_osd_ass(width, height, "")
    
    if timepos1 then
        
    timepos2 = mp.get_property("time-pos")
    timepos2_humanreadable = mp.get_property_osd("time-pos")
    
    if tonumber(timepos1) > tonumber(timepos2) then
            
            length = timepos1-timepos2
            start = timepos2
        start_humanreadable = timepos2_humanreadable
        end_humanreadable = timepos1_humanreadable
        msg.info("End frame set")
        
    elseif tonumber(timepos2) > tonumber(timepos1) then
        
        length = timepos2-timepos1
        start = timepos1
        start_humanreadable = timepos1_humanreadable
        end_humanreadable = timepos2_humanreadable
        msg.info("End frame set")
    
    else
    
        msg.error("Both frames are the same, ignoring the second one")
        mp.osd_message("Both frames are the same, ignoring the second one")
        timepos2 = nil
        return
           
    end
    
    timepos1 = nil
    mp.enable_key_bindings("draw_rectangle")
    call_gui_x264()
    
    else
        
    timepos1 = mp.get_property("time-pos")
    timepos1_humanreadable = mp.get_property_osd("time-pos")
        msg.info("Start frame set")
        mp.osd_message("Start frame set")
    
    end

end


------------
-- Encode --
------------

function encode_webm ()
    
    set_mouse_area = nil
    if rect_width == nil or rect_width == 0 then
        crop = ""
    else
        crop = math.floor(rect_width) .. ":" .. math.floor(rect_height) .. ":" .. math.ceil(rect_x1) .. ":" .. math.ceil(rect_y1)
	rect_width, rect_height= nil 
    end
    
    local video = mp.get_property("path")
    video = string.gsub(video, "'", "'\\''")
    local sid = mp.get_property("sid")
    local sub_visibility = mp.get_property("sub-visibility")
    local vf = mp.get_property("vf")
    if string.len(vf) > 0 then
        vf = vf .. ","
    end
    local sub_file_table = mp.get_property_native("options/sub-file")
    local sub_file = ""
    for index, param in pairs(sub_file_table) do
        sub_file = sub_file .. " --sub-file='" .. string.gsub(tostring(param), "'", "'\\''") .. "'"
    end
    local sub_auto = mp.get_property("options/sub-auto")
    local sub_delay = mp.get_property("sub-delay")
    local colormatrix_input_range = mp.get_property_native("colormatrix-input-range")    
    
    if options.use_pwd_instead then
    
        local pwd = os.getenv("PWD")
        pwd = string.gsub(pwd, "'", "'\\''")
        options.output_directory = "'" .. pwd .. "'"
        
    end
    
    local filename_ext = mp.get_property_osd("filename")
    filename_ext = string.gsub(filename_ext, "'", "'\\''")
    local filename = string.gsub(filename_ext, "%....$","")
    
    if string.len(filename) > 230 then
    
        filename = mp.get_property("options/title")
        if filename == 'mpv - ${media-title}' or string.len(filename) > 230 then
            filename = 'output'
        end
        
    end
    
    local path = mp.get_property("path", "")
    local dir, fil = mputils.split_path(path)

    local file_in = dir .. fil
    local file_out = dir .. filename .. "-out.webm"

    file_in = string.gsub(file_in, "'", "'\\''")
    file_out = string.gsub(file_out, "'", "'\\''")
    
    local full_command = '(ffmpeg -ss ' .. start .. ' -i \'' .. file_in .. '\' -t ' .. length .. ' -b:v ' .. bitrate .. 'M -vf scale=' .. scale .. ':-1 -quality good -cpu-used 0 -pass 1 ' .. audio .. ' ' .. subs .. ' -f webm /dev/null -y' 

    full_command = full_command .. ' && ffmpeg -ss ' .. start .. ' -i \'' .. file_in .. '\' -t ' .. length .. ' -b:v ' .. bitrate .. 'M -vf scale=' .. scale .. ':-1 -quality good -cpu-used 0 -pass 2 ' .. audio .. ' ' .. subs .. ' -f webm \'' .. file_out .. '\' -y'

    full_command = full_command .. ') && notify-send "Encode done!"'
   
    msg.info(full_command)
    os.execute(full_command)
    
end

function encode_gif ()
    
    set_mouse_area = nil
    if rect_width == nil or rect_width == 0 then
        crop = ""
    else
        crop = math.floor(rect_width) .. ":" .. math.floor(rect_height) .. ":" .. math.ceil(rect_x1) .. ":" .. math.ceil(rect_y1)
    rect_width, rect_height= nil 
    end
    
    local video = mp.get_property("path")
    video = string.gsub(video, "'", "'\\''")
    local sid = mp.get_property("sid")
    local sub_visibility = mp.get_property("sub-visibility")
    local vf = mp.get_property("vf")
    if string.len(vf) > 0 then
        vf = vf .. ","
    end
    local sub_file_table = mp.get_property_native("options/sub-file")
    local sub_file = ""
    for index, param in pairs(sub_file_table) do
        sub_file = sub_file .. " --sub-file='" .. string.gsub(tostring(param), "'", "'\\''") .. "'"
    end
    local sub_auto = mp.get_property("options/sub-auto")
    local sub_delay = mp.get_property("sub-delay")
    local colormatrix_input_range = mp.get_property_native("colormatrix-input-range")    
    
    if options.use_pwd_instead then
    
        local pwd = os.getenv("PWD")
        pwd = string.gsub(pwd, "'", "'\\''")
        options.output_directory = "'" .. pwd .. "'"
        
    end
    
    local filename_ext = mp.get_property_osd("filename")
    filename_ext = string.gsub(filename_ext, "'", "'\\''")
    local filename = string.gsub(filename_ext, "%....$","")
    
    if string.len(filename) > 230 then
    
        filename = mp.get_property("options/title")
        if filename == 'mpv - ${media-title}' or string.len(filename) > 230 then
            filename = 'output'
        end
        
    end
    
    local path = mp.get_property("path", "")
    local dir, fil = mputils.split_path(path)

    local file_in = dir .. fil
    local file_out = dir .. filename .. "-out.gif"

    file_in = string.gsub(file_in, "'", "'\\''")
    file_out = string.gsub(file_out, "'", "'\\''")
    
    local full_command = '(ffmpeg -ss ' .. start .. ' -i \'' .. file_in .. '\' -t ' .. length .. ' -vf scale=' .. scale .. ':-1 -r 24 \'' .. file_out .. '\' -y'

    full_command = full_command .. ') && notify-send "Encode done!"'
   
    msg.info(full_command)
    os.execute(full_command)
    
end

function encode_x264 ()
    
    set_mouse_area = nil
    if rect_width == nil or rect_width == 0 then
        crop = ""
    else
        crop = math.floor(rect_width) .. ":" .. math.floor(rect_height) .. ":" .. math.ceil(rect_x1) .. ":" .. math.ceil(rect_y1)
    rect_width, rect_height= nil 
    end
    
    local video = mp.get_property("path")
    video = string.gsub(video, "'", "'\\''")
    local sid = mp.get_property("sid")
    local sub_visibility = mp.get_property("sub-visibility")
    local vf = mp.get_property("vf")
    if string.len(vf) > 0 then
        vf = vf .. ","
    end
    local sub_file_table = mp.get_property_native("options/sub-file")
    local sub_file = ""
    for index, param in pairs(sub_file_table) do
        sub_file = sub_file .. " --sub-file='" .. string.gsub(tostring(param), "'", "'\\''") .. "'"
    end
    local sub_auto = mp.get_property("options/sub-auto")
    local sub_delay = mp.get_property("sub-delay")
    local colormatrix_input_range = mp.get_property_native("colormatrix-input-range")    
    
    if options.use_pwd_instead then
    
        local pwd = os.getenv("PWD")
        pwd = string.gsub(pwd, "'", "'\\''")
        options.output_directory = "'" .. pwd .. "'"
        
    end
    
    local filename_ext = mp.get_property_osd("filename")
    filename_ext = string.gsub(filename_ext, "'", "'\\''")
    local filename = string.gsub(filename_ext, "%....$","")
    
    if string.len(filename) > 230 then
    
        filename = mp.get_property("options/title")
        if filename == 'mpv - ${media-title}' or string.len(filename) > 230 then
            filename = 'output'
        end
        
    end
    
    local path = mp.get_property("path", "")
    local dir, fil = mputils.split_path(path)

    local file_in = dir .. fil
    local file_out = dir .. filename .. "-out.mkv"

    file_in = string.gsub(file_in, "'", "'\\''")
    file_out = string.gsub(file_out, "'", "'\\''")
    
    local full_command = '(ffmpeg -ss ' .. start .. ' -i \'' .. file_in .. '\' -t ' .. length .. ' -c:v libx264 -vf scale=' .. sheight .. ':' .. swidth .. ' -preset slow -qp ' .. quality .. ' -c:a copy -c:s copy -map 0 \'' .. file_out .. '\' -y'

    full_command = full_command .. ') && notify-send "Encode done! (' .. quality .. ')"'
   
    msg.info(full_command)
    os.execute(full_command)
    
end


---------
-- GUI --
---------

function call_gui_webm ()

    mp.resume_all()
    local handle = io.popen('yad --title="Convert Script" --center --form --separator="\n" --field="Resize to:NUM" "720" --field="Don’t resize at all:CHK" "false" --field="Include audio:CHK" "false" --field="Include subs:CHK" "false" --field="Bitrate (M):NUM" "3" --button="gtk-cancel:2" --button="gtk-ok:0" && echo "$?"')
    local yad = handle:read("*a")
    handle:close()
   
    if yad == "" then
        return
    end
    
    local yad_table = {}
    
    local i = 0
    for k in string.gmatch(yad, "[%a%d]+") do
       i = i + 1
       yad_table[i] = k
    end
    
    if (yad_table[3] == "FALSE") then
        scale = yad_table[1]
    else
        scale = "-1"
    end
    
    if yad_table[4] == "FALSE" then
        audio = '-an'
    else
        audio = ""
    end

    if yad_table[5] == "FALSE" then
        subs = '-sn'
    else
        subs = ""
    end
    
    bitrate = yad_table[6]

    mp.disable_key_bindings("draw_rectangle")
    mp.set_osd_ass(width, height, "")
    
    if yad_table[8] == "0" then
        encode_webm()
    end

end

function call_gui_gif ()

    mp.resume_all()
    local handle = io.popen('yad --title="Convert Script" --center --form --separator="\n" --field="Resize to:NUM" "320" --field="Don’t resize at all:CHK" "false" --button="gtk-cancel:2" --button="gtk-ok:0" && echo "$?"')
    local yad = handle:read("*a")
    handle:close()
   
    if yad == "" then
        return
    end
    
    local yad_table = {}
    
    local i = 0
    for k in string.gmatch(yad, "[%a%d]+") do
       yad_table[i] = k
       i = i + 1
    end
    
    if (yad_table[2] == "FALSE") then
        scale = yad_table[0]
    else
        scale = "-1"
    end

    --os.execute('notify-send "' .. scale .. '"')
    
    if yad_table[3] == "0" then
        encode_gif()
    end

end

function call_gui_x264 ()

    mp.resume_all()
    local handle = io.popen('yad --title="Convert Script" --center --form --separator="\n" --field="Resize height:NUM" "720" --field="Resize width:NUM" "480" --field="Don’t resize at all:CHK" "true" --field="Quality (0-51):NUM" "18" --button="gtk-cancel:2" --button="gtk-ok:0" && echo "$?"')
    local yad = handle:read("*a")
    handle:close()
   
    if yad == "" then
        return
    end
    
    local yad_table = {}
    
    local i = 0
    for k in string.gmatch(yad, "[%a%d]+") do
       yad_table[i] = k
       i = i + 1
    end

    if (yad_table[4] == "FALSE") then
        sheight = yad_table[0]
    else
        sheight = "-1"
    end

    if (yad_table[4] == "FALSE") then
        swidth = yad_table[2]
    else
        swidth = "-1"
    end
    
    if ((sheight ~= "-1" and swidth ~= "-1") and (tonumber(sheight)%2 ~= 0 or tonumber(swidth)%2 ~= 0)) then
        os.execute('notify-send "' .. sheight ..':' .. swidth .. '"')
        return
    end

    quality = yad_table[5];

    if yad_table[7] == "0" then
        encode_x264()
    end

end

mp.add_key_binding("alt+w", "convert_script_webm", convert_script_hotkey_call_webm)
mp.add_key_binding("alt+g", "convert_script_gif", convert_script_hotkey_call_gif)
mp.add_key_binding("alt+x", "convert_script_x264", convert_script_hotkey_call_x264)