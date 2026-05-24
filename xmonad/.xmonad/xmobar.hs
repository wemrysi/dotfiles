Config {
    font    = "xft:Fira Code:size=9:antialias=true:hinting=true",
    dpi     = 192,
    bgColor = "#000000",
    fgColor = "#ffffff",
    position = TopHM 48 0 264 0 0,
    lowerOnStart = True,
    commands = [
        Run Weather "KPSN" ["-t","<tempF>F <skyCondition>","-L","64","-H","77","-n","#CEFFAC","-h","#FFB6B0","-l","#96CBFE"] 36000,
        Run Cpu ["-t","Cpu: <total>%","-L","30","-H","60","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC","-w","3"] 10,
        Run Memory ["-t","Mem: <usedratio>%","-H","8192","-L","4096","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,
        Run Wireless "wlp0s20f3" ["-t","<essid>","-H","80","-L","40","-l","#FFB6B0","-h","#CEFFAC","-n","#FFFFCC"] 50,
        Run Network "wlp0s20f3" ["-t","<rx>, <tx>","-H","200","-L","10","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,
        Run Com "pamixer" ["--get-volume-human"] "vol" 10,
        Run Brightness ["-t","Lux: <percent>%","--","-D","intel_backlight"] 10,
        Run Battery ["-t","Bat: <left>% (<timeleft>)","-L","20","-H","80","-h","#CEFFAC","-l","#FFB6B0","-n","#FFFFCC"] 60,
        Run Date "%a %b %_d %H:%M" "date" 10,
        Run XMonadLog
    ],
    sepChar  = "%",
    alignSep = "}{",
    template = "%XMonadLog% }{ %cpu%   %memory%   %wlp0s20f3wi%: %wlp0s20f3%   Vol: %vol%   %bright%   %battery%   <fc=#FFFFCC>%date%</fc>   %KPSN%"
}
