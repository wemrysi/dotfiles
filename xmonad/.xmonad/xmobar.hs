-- xmobar config used by Vic Fryzel
-- Author: Vic Fryzel
-- http://github.com/vicfryzel/xmonad-config

-- This is setup for dual 1920x1200 monitors, with the left monitor as primary
Config {
    font = "xft:Fixed-10",
    dpi = 192,
    bgColor = "#000000",
    fgColor = "#ffffff",
    position = TopSize L 80 48,
    lowerOnStart = True,
    commands = [
        Run Weather "KEMT" ["-t","<tempF>F <skyCondition>","-L","64","-H","77","-n","#CEFFAC","-h","#FFB6B0","-l","#96CBFE"] 36000,
        Run Cpu ["-t","Cpu: <total>%","-L","30","-H","60","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC","-w","3"] 10,
        Run Memory ["-t","Mem: <usedratio>%","-H","8192","-L","4096","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,
        Run Wireless "wlp0s20f3" ["-t","<essid>","-H","80","-L","40","-l","#FFB6B0","-h","#CEFFAC","-n","#FFFFCC"] 50,
        Run Network "wlp0s20f3" ["-t","<rx>, <tx>","-H","200","-L","10","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,
--      Run Alsa "default" "Master" ["--","--alsactl=/run/current-system/sw/bin/alsactl","-C","#CEFFAC","-c","#FFB6B0"] 10,
        Run Volume "default" "Master" ["--","-C","#CEFFAC","-c","#FFB6B0"] 10,
        Run Brightness ["-t","Lux: <percent>%","--","-D","intel_backlight"] 10,
        Run Battery ["-t","Bat: <left>% (<timeleft>)"] 600,
        Run Date "%a %b %_d %H:%M" "date" 10,
        Run StdinReader
    ],
    sepChar = "%",
    alignSep = "}{",
    template = "%StdinReader% }{ %cpu%   %memory%   %wlp0s20f3wi%: %wlp0s20f3%   %default:Master%   %bright%   %battery%   <fc=#FFFFCC>%date%</fc>   %KEMT%"
}
