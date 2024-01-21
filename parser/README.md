# Profit-Taker Analyzer
**Approved tool by the Warframe Speedrunning community!  
 https://www.speedrun.com/wf/resources** 

This tool analyzes Profit-Taker runs from based on Warframe's log file, EE.log.  
It marks the time spent on each phase and the time spent on the parts that make up said phase.  
For the total time, there are two timing methods. The first timing method starts when you leave the elevator, and ends when the final blow is dealt to Profit-Taker. This is accurate up to a frame or two with the speedrun RTA timing.  
Another timing method is called *fight duration*. This timing method starts when you approach Profit-Taker and it first becomes vulnerable. This reduces the difference between the different spawning locations and better reflects your performance in casual runs where you leave the elevator earlier than in speedruns.

Example output:  
![image](https://user-images.githubusercontent.com/24490028/126034456-5551cfe2-1289-4ec3-bdeb-f37770bb8a3b.png)

**Downloading:**
* You can download the latest version by downloading the executable file [here](https://github.com/revoltage34/ptanalyzer/releases/latest).

**Usage:**  
* Either run the program to follow the game's log files and have your runs analyzed live.
* Or drag a specific log file onto the .exe file.

EE.log can be found in `%LOCALAPPDATA%/Warframe` (EE.log is reset on startup)  
Linux users will have to export the folder that contains /Warframe/EE.log as LOCALAPPDATA to get follow mode to work.

**Features:**
1. Analyzes specific log files by dragging one onto the .exe file.
2. Follows the game's log file analyze your runs live (survives game restarts!)
3. Displays the first shield element as soon as Profit-Taker spawns in follow mode.
4. Marks the best run and displays timestamps and phase durations.
5. Supports multiple Profit-Taker runs per EE.log
6. Detects the [leg regen bug](https://forums.warframe.com/topic/1228077-reliable-repro-cause-known-profit-taker-leg-regen-recovering-from-the-pylon-phase-fully-heals-its-legs-5-seconds-after-theyve-already-been-vulnerable/?tab=comments#comment-11997156) and marks the extra legs in red.
7. Detects bugs that lead to incomplete logs and indicates what information is missing.  
8. Automatically checks for newer versions.

**Limitations:**
1. The tool can only detect runs where you are the host.
2. The tool can only detect shield changes, not the cause of it. This means it cannot differentiate between it being destroyed and it getting reset by an Amp or the time limit.
3. The tool won't show stats runs that are affected by the [pylon stacking bug](https://forums.warframe.com/topic/1272496-profit-taker-pylons-landing-on-top-of-each-other-prevent-the-bounty-from-completing/) or other bugs that mess with the logs.

Feel free to contact me on Discord about this tool: **Iterniam#5829**
