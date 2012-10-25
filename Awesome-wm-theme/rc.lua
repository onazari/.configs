-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("scratch")
require("naughty")
require("vicious")
require("volume")
require("blingbling")

 --

-- {{{ Variable definitions
--get $HOME from the environement system
home   = os.getenv("HOME")
--get XDG_CONFIG
config_dir = awful.util.getdir("config")
-- Themes define colours, icons, and wallpapers
beautiful.init( config_dir .. "/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "terminator"
editor = "kate"
editor_cmd = terminal .. " -e \"" .. editor
browser="luakit"
-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ naughty theme
naughty.config.default_preset.font             = beautiful.notify_font 
naughty.config.default_preset.fg               = beautiful.notify_fg
naughty.config.default_preset.bg               = beautiful.notify_bg
naughty.config.presets.normal.border_color     = beautiful.notify_border
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
   names  = { "main", "www", "im", "devel", "player", "trans" },
   layout = { layouts[3], layouts[5], layouts[6], layouts[6], layouts[1], layouts[1]
 }}
 for s = 1, screen.count() do
     -- Each screen has its own tag table.
     tags[s] = awful.tag(tags.names, s, tags.layout)
 end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu

favAppsMenu = {
   { "firefox", "firefox" },
   { "pidgin", "pidgin" },
   { "kate", "kate" },
   { "emacs", "emacs" },
   { "mdic", "mdic" },
   { "tomighty", "java -jar /home/shahin/.tomighty.jar" }
}

othersMenu = {
   { "writer", "libreoffice --writer" },
   { "impress", "libreoffice --impress" },
   { "smplayer", "smplayer" },
   { "deluge", "deluge-gtk" },
   { "kget", "kget" },
   { "gimp", "gimp" },
   { "xpdf", "xpdf" }
}

myawesomemenu = {
   { "manual", terminal .. " -e \"man awesome\"" },
   { "edit config", "" .. editor .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit },
}

logoutmenu = {
   { "Suspend", "sudo /usr/sbin/pm-suspend" },
   { "Hibernate", "sudo /usr/sbin/pm-hibernate" },
   { "Suspend-Hybrid", "sudo /usr/sbin/pm-suspend-hybrid"}
}
mymainmenu = awful.menu({ items = { { "file manager", "dolphin" },
                                   { "terminal", terminal },
                                   { "fav apps", favAppsMenu },
                                   { "others", othersMenu },
                                   { "awesome", myawesomemenu, beautiful.awesome_icon, },
				   { "Logout", logoutmenu},
                                 }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- {{ My Widgets
--widget separator
separator = widget({ type = "textbox" })
separator.text  = "  "
-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)
--{{ Section des widget
--pango
    pango_small="size=\"small\""
    pango_x_small="size=\"x-small\""
    pango_xx_small="size=\"xx-small\""
    pango_bold="weight=\"bold\""

-- Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = { "us", "ir,us" }
kbdcfg.current = 1  -- us is our default layout
kbdcfg.widget = widget({ type = "textbox", align = "right" })
kbdcfg.widget.text = " " .. kbdcfg.layout[kbdcfg.current] .. " "
kbdcfg.switch = function ()
   kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
   local t = " " .. kbdcfg.layout[kbdcfg.current] .. " "
   kbdcfg.widget.text = t:sub(1,3)
   os.execute( kbdcfg.cmd .. t )
end
-- Mouse bindings
kbdcfg.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () kbdcfg.switch() end)
))
 netwidget = widget({ type = "textbox", name = "netwidget" })
 netwidget.text='Net: '
 my_net=blingbling.net.new()
 my_net:set_height(18)
 --activate popup with ip informations on the net widget
  my_net:set_ippopup()
 my_net:set_show_text(true)
 my_net:set_v_margin(3)

-- Memory Widget
memlable = widget({ type= "textbox"})
memlable.text = 'Mem: '
memwidget=blingbling.classical_graph.new()
memwidget:set_height(18)
memwidget:set_width(200)
memwidget:set_tiles_color("#00000022")
memwidget:set_show_text(true)
vicious.register(memwidget, vicious.widgets.mem, '$1', 10)

-- CPU Widget
cpulabel= widget({ type = "textbox" })
cpulabel.text='CPU: '
mycairograph=blingbling.classical_graph.new()
mycairograph:set_height(18)
mycairograph:set_width(200)
mycairograph:set_tiles_color("#00000022")
mycairograph:set_show_text(true)
mycairograph:set_label("Load: $percent %")
vicious.register(mycairograph, vicious.widgets.cpu,'$1',2)

--Cores
corelabel= widget({ type = "textbox"})
corelabel.text = 'Cores: '
 mycore1=blingbling.progress_graph.new()
 mycore1:set_height(18)
 mycore1:set_width(6)
 mycore1:set_filled(true)
 mycore1:set_h_margin(1)
 mycore1:set_filled_color("#00000033")
 vicious.register(mycore1, vicious.widgets.cpu, "$2")
  mycore2=blingbling.progress_graph.new()
 mycore2:set_height(18)
 mycore2:set_width(6)
 mycore2:set_filled(true)
 mycore2:set_h_margin(1)
 mycore2:set_filled_color("#00000033")
 vicious.register(mycore2, vicious.widgets.cpu, "$3")
  mycore3=blingbling.progress_graph.new()
 mycore3:set_height(18)
 mycore3:set_width(6)
 mycore3:set_filled(true)
 mycore3:set_h_margin(1)
 mycore3:set_filled_color("#00000033")
 vicious.register(mycore3, vicious.widgets.cpu, "$4")
  mycore4=blingbling.progress_graph.new()
 mycore4:set_height(18)
 mycore4:set_width(6)
 mycore4:set_filled(true)
 mycore4:set_h_margin(1)
 mycore4:set_filled_color("#00000033")
 vicious.register(mycore4, vicious.widgets.cpu, "$5")
--Filesystem Widget
 --Home
 my_fs_label = widget({ type = "textbox"})
 my_fs_label.text = '/home: '
 my_fs=blingbling.progress_bar.new()
 my_fs:set_height(18)
 my_fs:set_width(40)
 my_fs:set_show_text(false)
 my_fs:set_horizontal(true)  
 vicious.register( my_fs, vicious.widgets.fs, "${/home used_gb}", 599)
 --Root
  my_fs_root_label = widget({ type = "textbox"})
 my_fs_root_label.text = '/root: '
 my_fs_root=blingbling.progress_bar.new() 
 my_fs_root:set_height(18)
 my_fs_root:set_width(40)
 my_fs_root:set_v_margin(2)
 my_fs_root:set_show_text(false)
 my_fs_root:set_horizontal(true)
 vicious.register(my_fs_root, vicious.widgets.fs, "${/ used_gb}", 599)
 -- Volume Widget
 my_volume_label = widget({ type = "textbox"})
 my_volume_label.text = 'Vol: '
 my_volume=blingbling.volume.new()
 my_volume:set_height(18)
 my_volume:set_width(30)
 --bind the volume widget on the master channel
 my_volume:update_master()
 my_volume:set_master_control()
 my_volume:set_bar(true)
vicious.register(my_volume, vicious.widgets.volume, "$1", 1, "Master")

--  }}

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            separator, mytaglist[s],
            separator, mypromptbox[s], 
            layout = awful.widget.layout.horizontal.leftright
        },
        s == 1 and mysystray or nil, separator, 
        separator, mytasklist[s], separator, 
        layout = awful.widget.layout.horizontal.rightleft
    }

    -- Bottom Wibox
    mywibox[s] = awful.wibox({ position = "bottom", screen = s})
    mywibox[s].widgets = {
            {
	    netwidget, my_net, separator, my_fs_label, my_fs, separator, my_fs_root_label, my_fs_root,
            separator, memlable, memwidget,
            separator, cpulabel, mycairograph,
            separator, corelabel, mycore1, mycore2, mycore3, mycore4, separator, my_volume_label, my_volume, separator, 
            layout = awful.widget.layout.horizontal.leftright},
        --Left2Right Section
        mylayoutbox[s], separator, mytextclock, separator, kbdcfg.widget, 
        layout = awful.widget.layout.horizontal.rightleft
       }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Alt + Shift switches the current keyboard layout
    awful.key({ modkey }, "d", function (c) scratch.pad.set(c, 0.60, 0.60, true) end),
   awful.key({ modkey }, "F11", function () scratch.drop("gmrun") end),
    awful.key({ modkey }, "F12", function () scratch.drop("terminator", "bottom","center",0.90,0.40) end),
    awful.key({ "Mod1",           }, "Shift_L", function () kbdcfg.switch() end),
    awful.key({ "Mod1",           }, "Shift_R", function () kbdcfg.switch() end),
    awful.key({ modkey,           }, "Prior", function () volume("up", tb_volume) end),
    awful.key({ modkey,           }, "Next", function () volume("down", tb_volume) end),
    awful.key({ modkey,           }, "End", function () volume("mute", tb_volume) end),
    awful.key({                   }, "XF86AudioPlay", function () os.execute( "mpc toggle" ) end),
    awful.key({                   }, "XF86AudioStop", function () os.execute( "mpc stop" ) end),
    awful.key({                   }, "XF86AudioNext", function () os.execute( "mpc next" ) end),
    awful.key({                   }, "XF86AudioPrev", function () os.execute( "mpc prev" ) end),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
		     maximized_vertical   = false,
		     maximized_horizontal = false,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true, tag = tags[1][5]} },
    { rule = { name = "MDic Dictionary", instance = "mdic" }, 
    properties = {tag = tags[1][6]}},
    { rule = { class = "Smplayer" },
      properties = { floating = true, tag = tags[1][5]} },
    { rule = { class = "Hotot" },
      properties = { floating = true, tag = tags[1][2]} },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][3] } },
    { rule = { class = "Eclipse" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "gimp" },
      properties = { floating = true, tag = tags[1][6] } },
    { rule = { name = "File Operation Progress" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Firefox", name = "Downloads" },
      properties = { floating = true, tag = tags[1][2] } },
    { rule = { class = "Firefox", instance = "Global" },
      properties = { floating = true, tag = tags[1][2] } },
    { rule = { class = "Firefox", instance = "StylishEdit*" },
      properties = { floating = true, tag = tags[1][2] } },
    { rule = { class = "Firefox", instance = "DTA" },
      properties = { floating = true, tag = tags[1][2] } },
    { rule = { class = "Firefox", instance = "Toplevel" },
      properties = { floating = true, tag = tags[1][2] } },
    { rule = { class = "Firefox", instance = "Foxyproxy-options" },
      properties = { floating = true, tag = tags[1][2] } },
    { rule = { class = "Firefox", instance = "Netvideohunter" },
      properties = { floating = true, tag = tags[1][2] } },
    { rule = { class = "emsgui" },
      properties = { floating = true, tag = tags[1][7] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
awful.util.spawn_with_shell("conky")
awful.util.spawn_with_shell("mdic")
