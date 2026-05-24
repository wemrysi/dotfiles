import Graphics.X11.ExtraTypes.XF86
import System.Exit
import XMonad
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import qualified XMonad.StackSet as W
import qualified Data.Map        as M


------------------------------------------------------------------------
-- Terminal
--
myTerminal = "/run/current-system/sw/bin/alacritty"


------------------------------------------------------------------------
-- Workspaces
--
myWorkspaces = ["1:coms","2:web","3:code","4:compile","5:docs","6:game"] ++ map show [7..9]


------------------------------------------------------------------------
-- Window rules
--
myManageHook = composeAll
    [ className =? "discord"           --> doShift "1:coms"
    , className =? "firefox"           --> doShift "2:web"
    , resource  =? "desktop_window"    --> doIgnore
    , className =? "stalonetray"       --> doIgnore
    , title     =? "Path of Exile"     --> (doShift "6:game" <+> doFullFloat)
    , title     =? "Path of Exile 2"   --> (doShift "6:game" <+> doFullFloat)
    , title     =? "Last Epoch"        --> (doShift "6:game" <+> doFullFloat)
    , isFullscreen                     --> (doF W.focusDown <+> doFullFloat)
    ]


------------------------------------------------------------------------
-- Layouts
--
-- smartBorders removes borders when there is only one window or when
-- a window is fullscreen. ewmhFullscreen (applied in main) handles
-- _NET_WM_STATE_FULLSCREEN requests from apps like Firefox/Discord.
--
myLayout = smartBorders $ avoidStruts (
    Tall 1 (3/100) (1/2) |||
    Mirror (Tall 1 (3/100) (1/2)) |||
    tabbed shrinkText tabConfig |||
    Full |||
    spiral (6/7))


------------------------------------------------------------------------
-- Colors and borders
--
myNormalBorderColor  = "#7c7c7c"
myFocusedBorderColor = "#ffb6b0"

tabConfig = def {
    activeBorderColor = "#7C7C7C",
    activeTextColor = "#CEFFAC",
    activeColor = "#000000",
    inactiveBorderColor = "#7C7C7C",
    inactiveTextColor = "#EEEEEE",
    inactiveColor = "#000000"
}

xmobarTitleColor = "#FFB6B0"
xmobarCurrentWorkspaceColor = "#CEFFAC"

myBorderWidth = 1


------------------------------------------------------------------------
-- Key bindings
--
myModMask = mod1Mask

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  ----------------------------------------------------------------------
  -- Custom key bindings
  --

  -- Start a terminal.
  [ ((modMask .|. shiftMask, xK_Return),
     spawn $ XMonad.terminal conf)

  -- Lock the screen using i3lock.
  , ((modMask .|. controlMask, xK_l),
     spawn "i3lock --clock --indicator --time-str=\"%H:%M:%S\" --date-str=\"%A, %Y-%m-%d\"")

  -- Launch dmenu.
  , ((modMask, xK_p),
     spawn "dmenu_run -f --render_minheight 48")

  -- Take a screenshot in select mode.
  , ((modMask .|. shiftMask, xK_p),
     spawn "select-screenshot")

  -- Take full screenshot in multi-head mode.
  , ((modMask .|. controlMask .|. shiftMask, xK_p),
     spawn "screenshot")

  -- Mute volume.
  , ((noModMask, xF86XK_AudioMute),
     spawn "pamixer --toggle-mute")

  -- Decrease volume.
  , ((noModMask, xF86XK_AudioLowerVolume),
     spawn "pamixer -d 5")

  -- Increase volume.
  , ((noModMask, xF86XK_AudioRaiseVolume),
     spawn "pamixer -i 5")

  -- Decrease brightness.
  , ((noModMask, xF86XK_MonBrightnessDown),
     spawn "xbacklight -dec 5")

  -- Increase brightness.
  , ((noModMask, xF86XK_MonBrightnessUp),
     spawn "xbacklight -inc 5")

  -- Focus latest urgent window.
  , ((modMask, xK_u),
     focusUrgent)

  --------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  --

  -- Close focused window.
  , ((modMask .|. shiftMask, xK_c),
     kill)

  -- Cycle through the available layout algorithms.
  , ((modMask, xK_space),
     sendMessage NextLayout)

  --  Reset the layouts on the current workspace to default.
  , ((modMask .|. shiftMask, xK_space),
     setLayout $ XMonad.layoutHook conf)

  -- Resize viewed windows to the correct size.
  , ((modMask, xK_n),
     refresh)

  -- Move focus to the next window.
  , ((modMask, xK_Tab),
     windows W.focusDown)

  -- Move focus to the next window.
  , ((modMask, xK_j),
     windows W.focusDown)

  -- Move focus to the previous window.
  , ((modMask, xK_k),
     windows W.focusUp  )

  -- Move focus to the master window.
  , ((modMask, xK_m),
     windows W.focusMaster  )

  -- Swap the focused window and the master window.
  , ((modMask, xK_Return),
     windows W.swapMaster)

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_j),
     windows W.swapDown  )

  -- Swap the focused window with the previous window.
  , ((modMask .|. shiftMask, xK_k),
     windows W.swapUp    )

  -- Shrink the master area.
  , ((modMask, xK_h),
     sendMessage Shrink)

  -- Expand the master area.
  , ((modMask, xK_l),
     sendMessage Expand)

  -- Push window back into tiling.
  , ((modMask, xK_t),
     withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((modMask, xK_comma),
     sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((modMask, xK_period),
     sendMessage (IncMasterN (-1)))

  -- Quit xmonad.
  , ((modMask .|. shiftMask, xK_q),
     io (exitWith ExitSuccess))

  -- Restart xmonad.
  , ((modMask, xK_q),
     restart "xmonad" True)
  ]
  ++

  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
  ++

  -- mod-{w,e}, Switch to physical/Xinerama screens 1, 2
  -- mod-shift-{w,e}, Move client to screen 1, 2
  [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_w, xK_e] [0..]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings
--
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2),
       (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))
  ]


------------------------------------------------------------------------
-- Status bar pretty-printer
--

-- Pad a string to exactly n chars so the title section has a fixed width.
-- Must be applied before xmobarColor so color tags don't skew the length.
padToLen :: Int -> String -> String
padToLen n s = take n (s ++ repeat ' ')

myXmobarPP :: PP
myXmobarPP = xmobarPP
    { ppTitle   = xmobarColor xmobarTitleColor "" . padToLen 30 . shorten 30
    , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor ""
    , ppSep     = "   "
    , ppUrgent  = xmobarColor "yellow" "red" . xmobarStrip
    }


------------------------------------------------------------------------
-- Startup hook
--
myStartupHook = return ()


------------------------------------------------------------------------
-- Run xmonad
--
-- Wrapping order (outermost first):
--   ewmhFullscreen  - handles _NET_WM_STATE_FULLSCREEN requests from apps
--   ewmh            - sets up EWMH hints so modern apps work correctly
--   docks           - makes xmobar/stalonetray reserve screen space
--   withUrgencyHook - draws a red border on urgent windows
--   withSB          - spawns xmobar and wires up the log hook via DBus
--
main :: IO ()
main = xmonad
     . ewmhFullscreen
     . ewmh
     . docks
     . withUrgencyHook (BorderUrgencyHook "#ff0000")
     . withSB (statusBarProp "xmobar ~/.xmonad/xmobar.hs" (pure myXmobarPP))
     $ defaults


------------------------------------------------------------------------
-- Configuration record
--
defaults = def {
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,
    keys               = myKeys,
    mouseBindings      = myMouseBindings,
    layoutHook         = myLayout,
    manageHook         = myManageHook,
    startupHook        = myStartupHook
}
