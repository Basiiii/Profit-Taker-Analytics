import json
import os
import sys
from collections import defaultdict
from math import nan, isnan
from time import sleep
from typing import Iterator, Callable, Optional, Union

from flask import Flask
from threading import Thread
from json import dumps, load, dump
from datetime import datetime, timedelta
from waitress import serve
import copy
import socket

from src.enums.damage_types import DT
from src.exceptions.bugged_run import BuggedRun
from src.exceptions.log_end import LogEnd
from src.exceptions.run_abort import RunAbort

class PTConstants:
    SHIELD_SWITCH = 'SwitchShieldVulnerability'
    SHIELD_PHASE_ENDINGS = {1: 'GiveItem Queuing resource load for Transmission: '  
                               '/Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourInterPrTk0920TheBusiness',
                            3: 'GiveItem Queuing resource load for Transmission: '
                               '/Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourInterPrTk0890TheBusiness',
                            4: 'GiveItem Queuing resource load for Transmission: '
                               '/Lotus/Sounds/Dialog/FortunaOrbHeist/Business/DBntyFourSatelReal0930TheBusiness'}
    LEG_KILL = 'Leg freshly destroyed at part'
    BODY_VULNERABLE = 'Camper->StartVulnerable() - The Camper can now be damaged!'
    STATE_CHANGE = 'CamperHeistOrbFight.lua: Landscape - New State: '
    PYLONS_LAUNCHED = 'Pylon launch complete'
    PHASE_1_START = 'Orb Fight - Starting first attack Orb phase'
    PHASE_ENDS = {1: 'Orb Fight - Starting second attack Orb phase',
                  2: 'Orb Fight - Starting third attack Orb phase',
                  3: 'Orb Fight - Starting final attack Orb phase',
                  4: ''}
    FINAL_PHASE = 4

class Globals:
    RUNFORMAT = {}
    STARTINGTIME = None
    LASTRUNTIME = 0.0
    LASTBUGGEDRUN = None
    RUNCOUNT = None

class MiscConstants:
    STARTTIME = 'Sys [Diag]: Current time:'
    NICKNAME = 'Net [Info]: name: '
    SQUAD_MEMBER = 'loadout loader finished.'
    HEIST_START = 'jobId=/Lotus/Types/Gameplay/Venus/Jobs/Heists/HeistProfitTakerBountyFour'
    HOST_MIGRATION = '"jobId" : "/Lotus/Types/Gameplay/Venus/Jobs/Heists/HeistProfitTakerBountyFour'
    HEIST_ABORT = 'SetReturnToLobbyLevelArgs: '
    ELEVATOR_EXIT = 'EidolonMP.lua: EIDOLONMP: Avatar left the zone'
    BACK_TO_TOWN = 'EidolonMP.lua: EIDOLONMP: TryTownTransition'
    ABORT_MISSION = 'GameRulesImpl - changing state from SS_STARTED to SS_ENDING'



class RelRun:

    def __init__(self,
                 run_nr: int,
                 bugged_run: bool,
                 nickname: str,
                 squad_members: set[str],
                 pt_found: float,
                 phase_durations: dict[int, float],
                 shield_phases: dict[float, list[tuple[DT, float]]],    # phase -> list(tuple(type, rev time))
                 legs: dict[int, list[tuple[str, float]]],                          # phase -> list(rev time)
                 body_dur: dict[int, float],
                 pylon_dur: dict[int, float],
                 run_duration: float):
        self.run_nr = run_nr
        self.bugged_run = bugged_run
        self.nickname = nickname
        self.squad_members = squad_members
        self.pt_found = pt_found
        self.phase_durations = phase_durations
        self.shield_phases = shield_phases
        self.legs = legs
        self.body_dur = body_dur
        self.pylon_dur = pylon_dur
        self.best_run = False
        self.best_run_yet = False
        self.run_duration = run_duration

    def __str__(self):
        return '\n'.join((f'{key}: {val}' for key, val in vars(self).items()))

    @property
    def length(self):
        return self.phase_durations[4] if not self.bugged_run else self.run_duration

    @property
    def shield_sum(self) -> float:
        """Sum of shield times over all phases, excluding the nan values."""
        return sum(time for times in self.shield_phases.values() for _, time in times if not isnan(time))

    @property
    def leg_sum(self) -> float:
        """Sum of the leg times over all phases."""
        return sum(time[1] for times in self.legs.values() for time in times)

    @property
    def body_sum(self) -> float:
        """Sum of the body times over all phases."""
        return sum(self.body_dur.values())

    @property
    def pylon_sum(self) -> float:
        """"Sum of the pylon times over all phases."""
        return sum(self.pylon_dur.values())

    @property
    def sum_of_parts(self) -> float:
        """"Sum of the individual parts of the fight. This cuts out some animations/waits."""
        return self.shield_sum + self.leg_sum + self.body_sum + self.pylon_sum

    @property
    def shields(self) -> list[tuple[str, float]]:
        """The shields without their phases, flattened."""
        return [shield_tuple for shield_phase in self.shield_phases.values() for shield_tuple in shield_phase]


    def to_json(self):
        """Convert a RelRun object into a json object suitable for display on the GUI.

        Returns:
            json: Full run object.
        """
        print(self.legs[2])
        fullRunFormat = copy.deepcopy(Globals.RUNFORMAT)
        fullRunFormat["total_duration"] = self.length
        fullRunFormat["total_shield"] = self.shield_sum
        fullRunFormat["total_leg"] = self.leg_sum
        fullRunFormat["total_body"] = self.body_sum
        fullRunFormat["total_pylon"] = self.pylon_sum
        fullRunFormat["flight_duration"] = self.pt_found
        fullRunFormat["bugged_run"] = self.bugged_run

        fullRunFormat["time_stamp"] = datetime.now().isoformat()
        fullRunFormat["best_run"] = self.best_run_yet

        fullRunFormat["squad_members"] = list(self.squad_members)
        fullRunFormat["nickname"] = self.nickname
        fullRunFormat["file_name"] = Analyzer.get_run_time().strftime('%Y%m%d_%H%M%S')
        fullRunFormat["pretty_name"] = Analyzer.get_next_run_string()

        fullRunFormat["phase_1"]["phase_time"] = self.phase_durations[1]
        fullRunFormat["phase_1"]["total_shield"] = sum(i for _, i in self.shield_phases[1])
        fullRunFormat["phase_1"]["total_leg"] = sum(leg[1] for leg in self.legs[1])
        fullRunFormat["phase_1"]["shield_change_times"] = [i for _,i in self.shield_phases[1]]
        fullRunFormat["phase_1"]["shield_change_types"] = [i.value for i,_ in self.shield_phases[1]]
        fullRunFormat["phase_1"]["leg_break_times"] = [leg[1] for leg in self.legs[1]]
        fullRunFormat["phase_1"]["leg_break_order"] = [leg[0] for leg in self.legs[1]]
        fullRunFormat["phase_1"]["body_kill_time"] = self.body_dur[1]
        fullRunFormat["phase_1"]["pylon_time"] = self.pylon_dur[1]
        
        fullRunFormat["phase_2"]["phase_time"] = self.phase_durations[2]
        fullRunFormat["phase_2"]["total_leg"] = sum(leg[1] for leg in self.legs[2])
        fullRunFormat["phase_2"]["leg_break_times"] = [leg[1] for leg in self.legs[2]]
        fullRunFormat["phase_2"]["leg_break_order"] = [leg[0] for leg in self.legs[2]]
        fullRunFormat["phase_2"]["body_kill_time"] = self.body_dur[2]

        fullRunFormat["phase_3"]["phase_time"] = self.phase_durations[3]
        fullRunFormat["phase_3"]["total_leg"] = sum(leg[1] for leg in self.legs[3])
        fullRunFormat["phase_3"]["leg_break_times"] = [leg[1] for leg in self.legs[3]]
        fullRunFormat["phase_3"]["leg_break_order"] = [leg[0] for leg in self.legs[3]]
        fullRunFormat["phase_3"]["body_kill_time"] = self.body_dur[3]
        fullRunFormat["phase_3"]["total_shield"] = sum(i for _, i in self.shield_phases[3])
        fullRunFormat["phase_3"]["shield_change_times"] = [i for _,i in self.shield_phases[3]]
        fullRunFormat["phase_3"]["shield_change_types"] = [i.value for i,_ in self.shield_phases[3]]

        # Check if there are enough pylon phases to indicate a second pylon phase was recorded.
        if len(self.pylon_dur) > 1:
            fullRunFormat["phase_3"]["pylon_time"] = self.pylon_dur[3]

        fullRunFormat["phase_4"]["phase_time"] = self.phase_durations[4]
        fullRunFormat["phase_4"]["total_leg"] = sum(leg[1] for leg in self.legs[4])
        fullRunFormat["phase_4"]["leg_break_times"] = [leg[1] for leg in self.legs[4]]
        fullRunFormat["phase_4"]["leg_break_order"] = [leg[0] for leg in self.legs[4]]
        fullRunFormat["phase_4"]["body_kill_time"] = self.body_dur[4]
        fullRunFormat["phase_4"]["total_shield"] = sum(i for _, i in self.shield_phases[4])
        fullRunFormat["phase_4"]["shield_change_times"] = [i for _,i in self.shield_phases[4]]
        fullRunFormat["phase_4"]["shield_change_types"] = [i.value for i,_ in self.shield_phases[4]]

        return fullRunFormat
        

class BrokenRun(RelRun):

    def __init__(self,
                 nickname: str,
                 squad_members: set[str],
                 total_time: float):
        self.nickname = nickname
        self.squad_members = squad_members
        self.total_time = total_time

    

    def to_json(self):
        """
        Convert a broken run to json format, containing only the most important information.

        Returns:
            json: The run format.
        """
        fullRunFormat = copy.deepcopy(Globals.RUNFORMAT)
        fullRunFormat["total_duration"] = self.total_time
        fullRunFormat["file_name"] = Analyzer.get_run_time().strftime('%Y%m%d_%H%M%S')
        fullRunFormat["squad_members"] = list(self.squad_members)
        fullRunFormat["nickname"] = self.nickname
        fullRunFormat["aborted_run"] = True
        fullRunFormat["time_stamp"] = datetime.now().isoformat()
        fullRunFormat["pretty_name"] = Analyzer.get_next_run_string()

        return fullRunFormat

class AbsRun:

    def __init__(self, run_nr: int):
        self.run_nr = run_nr
        self.bugged_run = False
        self.nickname = ''
        self.squad_members: set[str] = set()
        self.heist_start = 0.0
        self.pt_found = 0.0
        self.shield_phases: dict[float, list[tuple[DT, float]]] = defaultdict(list)  # phase -> list((type, abs time))
        self.shield_phase_endings: dict[int, float] = defaultdict(float)  # phase -> abs time
        self.legs: dict[int, list[tuple[str, float]]] = defaultdict(list)  # phase -> list(absolute time)
        self.body_vuln: dict[int, float] = {}  # phase -> vuln-time
        self.body_kill: dict[int, float] = {}  # phase -> kill-time
        self.pylon_start: dict[int, float] = {}  # phase -> start-time
        self.pylon_end: dict[int, float] = {}  # phase -> end-time
        self.final_time: Optional[float] = None

    def __str__(self):
        return '\n'.join((f'{key}: {val}' for key, val in vars(self).items()))

    def post_process(self) -> None:
        """
        Reorders some timing information to be more consistent with what we expect rather than what we get
        Throws `BuggedRun` if no shield elements were recorded for the final shield phase.
        """
        # Take the final shield from shield phase 3.5 and prepend it to phase 4.
        if len(self.shield_phases[3.5]) > 0:  # If the player is too fast, there won't be phase 3.5 shields.
            self.shield_phases[4] = [self.shield_phases[3.5].pop()] + self.shield_phases[4]

        # Remove the extra shield from phase 4.
        if (not self.bugged_run):
            try:
                self.shield_phases[4].pop()
            except IndexError:
                raise BuggedRun(self, ['No shields were recorded in phase 4.']) from None

    def check_run_integrity(self) -> None:
        """
        Checks whether all required information is present to convert the run into a run with relative timings.
        If not all information is present, this method throws BuggedRun with the failure reasons.
        """
        failure_reasons = []
        for phase in [1, 2, 3, 4]:
            # Shield phases (phase 1, 3, 4) have at least 3 shields per phase.
            # The default is 5 shields, but because shots damage is capped to the shield element phase's max HP
            # instead of the remaining phase's max HP, a minimum of 3 elements per shield phase can be achieved
            if phase in [1, 3, 4] and len(self.shield_phases[phase]) < 3:
                failure_reasons.append(f'{len(self.shield_phases[phase])} shield elements were recorded in phase '
                                       f'{phase} but at least 3 shield elements were expected.')

            # Every phase has an armor phase, and every armor phase needs at least 4 legs to be taken down
            # When less than 4 legs are recorded to be taken out, obviously there's a bug
            if len(self.legs[phase]) < 4:
                failure_reasons.append(f'{len(self.legs[phase])} legs were recorded in phase {phase} but at least 4 '
                                       f'legs were expected.')

            # It is intended for 4 legs to be taken out. Because of the leg regen bug, up to 8 legs can be taken out
            # If somehow more than 8 legs are taken out per phase, that signifies an even worse bug
            # Since 'even worse bugs' tend to corrupt the logs, so we print a warning to the user
            # This tool should still be able to convert and display it, so it doesn't fail the integrity check
            #if len(self.legs[phase]) > 8:
               # print(color(f'{len(self.legs[phase])} leg kills were recorded for phase {phase}.\n'
               #            f'If you have a recording of this run and the fight indeed bugged out, please '
               #            f'report the bug to Warframe.\n'
               #            f'If you think the bug is with the analyzer, contact the creator of this tool instead.',
               #            fg.li_red))

            # The time at which the body becomes vulnerable and is killed during the armor phase has to be present
            if phase not in self.body_vuln:
                failure_reasons.append(f'Profit-Taker\'s body was not recorded as being vulnerable in phase {phase}.')
            if phase not in self.body_kill:
                failure_reasons.append(f'Profit-Taker\'s body was not recorded as being killed in phase {phase}.')

            # If in the pylon phases (phase 1 and 3) the pylon start- or end time are not recorded, then the
            # logs (and probably fight) are bugged. The run cannot be converted.
            if phase in [1, 3]:
                if phase not in self.pylon_start:
                    failure_reasons.append(f'No pylon phase start time was recorded in phase {phase}.')
                if phase not in self.pylon_end and not self.bugged_run:
                    print("You done fucked up")
                    failure_reasons.append(f'No pylon phase end time was recorded in phase {phase}.')

        if failure_reasons:
            raise BuggedRun(self, failure_reasons)
        # Else: return none implicitly


    def to_broken(self) -> BrokenRun:
        """
        Convert the absolute timing run into a broken run object with relative timings.

        Not all information will be present, but these ones are sure to be there (surely).

        Returns:
            BrokenRun: A broken run object containing minimal information about the run.
        """ 
            
        if self.final_time is not None and self.heist_start is not None:
            total_time = (self.final_time - self.heist_start) if (self.final_time - self.heist_start) > 0 else 0.0
        else:
            total_time = 0.0
        return BrokenRun(total_time=total_time, squad_members=self.squad_members, nickname=self.nickname)

    def to_rel(self) -> RelRun:
        """
        Converts this AbsRun with absolute timings to RelRun with relative timings.

        If not all information is present, a `BuggedRun` exception is thrown.
        """
        self.check_run_integrity()
        pt_found = self.pt_found - self.heist_start
        phase_durations = {}
        shield_phases = defaultdict(list)
        legs = defaultdict(list)
        body_dur = {}
        pylon_dur = {}

        previous_timestamp = self.pt_found
        for phase in [1, 2, 3, 4]:
            if phase in [1, 3, 4]:  # Phases with shield phases
                # Register the times and elements for the shields
                for i in range(len(self.shield_phases[phase]) - 1):
                    shield_type, _ = self.shield_phases[phase][i]
                    _, shield_end = self.shield_phases[phase][i + 1]

                    # If the run is bugged, the first shield phase time can not
                    # be calculated in phase 4.
                    if (self.bugged_run and phase == 4 and i == 0):
                        shield_phases[phase].append((shield_type, 0.0))
                    else:
                        shield_phases[phase].append((shield_type, shield_end - previous_timestamp))
                    previous_timestamp = shield_end
                # The time of the final shield is determined by the shield_end transmission
                shield_phases[phase].append((self.shield_phases[phase][-1][0],
                                             self.shield_phase_endings[phase] - previous_timestamp))
                previous_timestamp = self.shield_phase_endings[phase]
            # Every phase has an armor phase
            for leg in self.legs[phase]:
                leg_time = leg[1]
                leg_type = leg[0]
                legs[phase].append((leg_type, leg_time - previous_timestamp))
                previous_timestamp = leg_time
            body_dur[phase] = self.body_kill[phase] - self.body_vuln[phase]
            previous_timestamp = self.body_kill[phase]

            if phase in [1, 3]:  # Phases with pylon phases

                # If the run is bugged, information on pylon phase 3 will not be available.
                if not (self.bugged_run and phase == 3):
                    pylon_dur[phase] = self.pylon_end[phase] - self.pylon_start[phase]
                    previous_timestamp = self.pylon_end[phase]

            # Set phase duration
            phase_durations[phase] = previous_timestamp - self.heist_start

        # Set phase 3.5 shields (possibly none on very fast runs)
        shield_phases[3.5] = [(shield, nan) for shield, _ in self.shield_phases[3.5]]

        run_duration = self.final_time - self.heist_start

        return RelRun(self.run_nr, self.bugged_run, self.nickname, self.squad_members, pt_found,
                      phase_durations, shield_phases, legs, body_dur, pylon_dur, run_duration)

    #@property
    #def failed_run_duration_str(self):
    #    if self.final_time is not None and self.heist_start is not None:
    #        return f'{fg.cyan}If Profit-Taker was killed, the run likely lasted around ' \
    #               f'{fg.li_cyan}{time_str(self.final_time - self.heist_start, "units")}.\n'
    #    return ''


class Analyzer:

    def __init__(self):
        self.follow_mode = False
        self.runs: list[Union[RelRun, RunAbort, BuggedRun]] = []
        self.proper_runs: list[RelRun] = []

    def initAPI(self):
        """Initiate the Flask application responsible for the API.
        """
        app = Flask(__name__)
        self.lastRun = {}
        self.lastRunTime = {}

        @app.route("/last_run_time", methods= ['GET'])
        def last_run_time():
            """Return the time of the last logged run.

            Returns:
                dict: The last logged run.
            """
            return self.lastRunTime
        
        @app.route("/last_run", methods= ['GET'])
        def last_run():
            """Return the last run that was logged.

            Returns:
                dict: The last run that was logged.
            """
            return self.lastRun
        
        # @app.route("/healthcheck", methods= ['GET'])
        # def healthcheck():
        #     """Return the status of the parser.

        #     Returns:
        #         dict: the of the parser.
        #     """
        #     return {'status': 'ok'}

        try:
            # Find an open port.
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.bind(('localhost', 0))
            port = sock.getsockname()[1]
            sock.close()

            # Write the open port to a text file to be used by the application.
            # Determine the base directory based on whether we're running a .py or .exe file
            if getattr(sys, 'frozen', False):
                bin_dir = os.path.dirname(sys.executable)
            else:
                bin_dir = os.path.dirname(os.path.realpath(__file__))

            file_name = os.path.join(bin_dir, "port.txt")
            with open(file_name, 'w', encoding="UTF-8") as port_file:
                port_file.write(str(port))

            # Start the application on a seperate thread.
            Thread(target=lambda: serve(app, host="127.0.0.1", port=port)).start()
        except Exception as e:
            print(e)

    @staticmethod
    def get_run_time():
        """
        Get the absolute time a run took place.
        Returns:
            datetime: datetime object
        """
        return Globals.STARTINGTIME + timedelta(seconds=Globals.LASTRUNTIME)

    def get_next_run_string():
        if Globals.RUNCOUNT is None:
            # Determine the base directory based on whether we're running a .py or .exe file
            if getattr(sys, 'frozen', False):
                base_dir = os.path.dirname(sys.executable)
            else:
                base_dir = os.path.dirname(os.path.realpath(__file__))

            # Go back one directory and into "storage" folder
            storage_folder = os.path.join(base_dir, '..', 'storage')
            directory = storage_folder

            count = len([f for f in os.listdir(directory) if f.endswith('.json')])
            Globals.RUNCOUNT = count + 1
            return f'Run #{Globals.RUNCOUNT}'

        Globals.RUNCOUNT += 1
        return f"Run #{Globals.RUNCOUNT}"
    
    def setLastRun(self, data):
        self.lastRun = data

    def run(self):
        self.initAPI()

        root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        
        json_path = os.path.join(root_dir, "src", "json", "run_format.json")

        with open(json_path, 'r', encoding="UTF-8") as file:
            Globals.RUNFORMAT = load(file)

        filename = self.get_file()
        if self.follow_mode:
            self.follow_log(filename)
        else:
            self.analyze_log(filename)

    def get_file(self) -> str:
        try:
            self.follow_mode = False
            return sys.argv[1]
        except IndexError:
            # print(fr"{fg.li_grey}Opening Warframe's default log from %LOCALAPPDATA%/Warframe/EE.log in follow mode.")
            # print('Follow mode means that runs will appear as you play. '
            #       'The first shield will also be printed when Profit-Taker spawns.')
            # print('Note that you can analyze another file by dragging it into the exe file.')
            self.follow_mode = True
            try:
                return os.getenv('LOCALAPPDATA') + r'/Warframe/EE.log'
            except TypeError:
                #print(f'{fg.li_red}Hi there Linux user! Check the README on github.com/revoltage34/ptanalyzer or '
                #      f'idalon.com/pt to find out how to get follow mode to work.')
                #print(f'{rs.fg}Press ENTER to exit...')
                input()  # input(prompt) doesn't work with color coding, so we separate it from the print.
                exit(-1)

    @staticmethod
    def follow(filename: str):
        """generator function that yields new lines in a file"""            
        known_size = os.stat(filename).st_size
        with open(filename, 'r', encoding="UTF-8") as file:
            # Start infinite loop
            cur_line = []  # Store multiple parts of the same line to deal with the logger committing incomplete lines.
            while True:
                if (new_size := os.stat(filename).st_size) < known_size:
                    #print(f'{fg.white}Restart detected.')
                    file.seek(0)  # Go back to the start of the file
                    #print('Successfully reconnected to ee.log. Now listening for new Profit-Taker runs.')
                known_size = new_size

                # Yield lines until the last line of file and follow the end on a delay
                while line := file.readline():
                    cur_line.append(line)  # Store whatever is found.
                    if line[-1] == '\n':  # On newline, commit the line
                        yield ''.join(cur_line)
                        cur_line = []
                # No more lines are in the file - wait for more input before we yield it.
                sleep(.1)

    def analyze_log(self, dropped_file: str):
        with open(dropped_file, 'r', encoding="UTF-8") as it:
            try:
                require_heist_start = True
                while True:
                    try:
                        run = self.read_run(it, len(self.runs) + 1, require_heist_start).to_rel()
                        formattedRun = run.to_json()
                        self.lastRun = formattedRun
                        self.runs.append(run)
                        self.proper_runs.append(run)
                        require_heist_start = True
                    except RunAbort as abort:
                        self.runs.append(abort)
                        require_heist_start = abort.require_heist_start
                    except BuggedRun as buggedRun:
                        self.runs.append(buggedRun)
                        require_heist_start = True
            except LogEnd:
                pass

        # Determine the best run
        if len(self.proper_runs) > 0:
            best_run = min(self.proper_runs, key=lambda run_: run_.length)
            best_run.best_run = True

        input()  # input(prompt) doesn't work with color coding, so we separate it in a print and an empty input.

    def store_run(self, run):
        """
        Store the run in a json file so the app can use it later.

        Args:
            run (json): The run to be saved, in json format.
        """
        # Determine the base directory based on whether we're running a .py or .exe file
        if getattr(sys, 'frozen', False):
            base_dir = os.path.dirname(sys.executable)
        else:
            base_dir = os.path.dirname(os.path.realpath(__file__))

        # Go back one directory and into "storage" folder
        storage_folder = os.path.join(base_dir, '..', 'storage')
        
        # Create filename
        time_diff = self.get_run_time()
        fileName = os.path.join(storage_folder, time_diff.strftime('%Y%m%d_%H%M%S') + ".json")
        
        # Check if file exists before writing
        if not os.path.exists(fileName):
            with open(fileName, "w", encoding="UTF-8") as file:
                dump(run, file)
        else:
            # Lower the count by 1 because the run was ignored
            Globals.RUNCOUNT -= 1
            
    def set_format_fields(self, kvpair: dict, format: dict):
        """Set specific fields in the run format to specific values.

        Args:
            kvpair (dict): The keys and values to insert.
            format (dict): The format to modify.
        """
        runFormat = copy.deepcopy(format)
        for key, value in kvpair.items():
            runFormat[key] = value

        return runFormat


    def follow_log(self, filename: str):

        # Wait for the log file to be generated.
        while not self.check_log_file_status(filename):
            sleep(1)
            self.setLastRun(dumps(self.set_format_fields({"status": "LogFileMissing"}, Globals.RUNFORMAT)))

        # Initialize the endpoint to inform the parser that no runs were found.
        self.setLastRun(dumps(self.set_format_fields({"status": "LogFileEmpty"}, Globals.RUNFORMAT)))

        it = Analyzer.follow(filename)
        self.store_start_time(it)
        best_time = float('inf')
        require_heist_start = True
        while True:
            try:
                run = self.read_run(it, len(self.runs) + 1, require_heist_start).to_rel()
                
                self.runs.append(run)
                self.proper_runs.append(run)
                require_heist_start = True

                if run.length < best_time:
                    best_time = run.length
                    run.best_run_yet = True

                # Format the run to json format.
                formattedRun = run.to_json()

                # Store the run in a json file.
                self.store_run(formattedRun)
            
                # Ensure the run numbering is up to date
                formattedRun['pretty_name'] = f'Run #{Globals.RUNCOUNT}'
                modifiedFormattedRun = json.dumps(formattedRun)
                formattedRun = modifiedFormattedRun
                
                # Add the run to the last_run endpoint.
                self.lastRun = formattedRun
                self.lastRunTime = {"date": datetime.now().isoformat()}
            except RunAbort as abort:

                # Get the latest run that was broken.
                broken_run = Globals.LASTBUGGEDRUN.to_broken().to_json()

                # Store the run in run history.
                self.store_run(broken_run)
                broken_run = dumps(broken_run)

                # Make sure the run is available in the endpoint.
                self.lastRun = broken_run
                #print(abort)
                self.runs.append(abort)
                require_heist_start = abort.require_heist_start
            except BuggedRun as buggedRun:
                #print(buggedRun)  # Print reasons why the run failed
                self.runs.append(buggedRun)
                require_heist_start = True

    def read_run(self, log: Iterator[str], run_nr: int, require_heist_start=False) -> AbsRun:
        """
        Reads a run.
        :param log: Iterator of the ee.log, expects a line with every next() call.
        :param run_nr: The number assigned to this run if it does not end up being aborted.
        :param require_heist_start: Indicate whether the start of this run indicates a previous run that was aborted.
        Necessary to properly initialize this run.
        :raise RunAbort: The run was aborted, had a bugged kill sequence, or restarted before it was completed.
        :raise BuggedRun: The run was completed but has missing information.
        :return: Absolute timings from the fight.
        """
        # Find heist load.
        if require_heist_start:  # Heist load is not required if the previous abort signifies the start of a new mission
            Analyzer.skip_until_one_of(log, [lambda line: MiscConstants.HEIST_START in line])

        run = AbsRun(run_nr)

        for phase in [1, 2, 3, 4]:
            self.register_phase(log, run, phase)  # Adds information to run, including the start time
        run.post_process()  # Apply shield phase corrections & check for run integrity

        return run
    
    def check_log_file_status(self, path):
        return os.path.exists(path)

    def store_start_time(self, log: Iterator[str]):
        """
        Get the time the log was generated.

        Args:
            log (Iterator[str]): The log in question.

        Raises:
            LogEnd: The log has ended.
        """
        while True:
            try:
                line = next(log)
            except StopIteration:
                raise LogEnd()
            if MiscConstants.STARTTIME in line:
                Globals.STARTINGTIME = datetime.strptime(" ".join(line.split()[6:10]), "%b %d %H:%M:%S %Y")
                return
        
    def idLeg(self, line):
        legNames = {"ARM_LEFT": "FL", "ARM_RIGHT": "FR", "LEG_LEFT": "BL", "LEG_RIGHT": "BR"}

        for key in legNames.keys():
            if key in line:
                return legNames[key]

    def register_phase(self, log: Iterator[str], run: AbsRun, phase: int) -> None:
        """
        Registers information to `self` for the current phase based on the information found in the logs.
        """
        kill_sequence = 0
        shield_count = 0
        last_shield_time = 0
        while True:  # match exists for phases 1-3, kill_sequence for phase 4.
            pt_line_match = True
            try:
                line = next(log)
            except StopIteration:
                raise LogEnd()

            # Check for PT specific messages
            if PTConstants.SHIELD_SWITCH in line:  # Shield switch
                # Shield_phase '3.5' is for when shields swap during the pylon phase in phase 3.
                shield_phase = 3.5 if phase == 3 and 3 in run.pylon_start else phase
                run.shield_phases[shield_phase].append(Analyzer.shield_from_line(line))
                
                # Check if the run is bugged based on the current phase, how many times the body has been killed and
                # if the second pylon phase has started. If the 
                if phase == 3 and kill_sequence == 2 and 3 in run.shield_phase_endings and 3 in run.pylon_start:
                    if (Analyzer.time_from_line(line) - last_shield_time) < 25 and shield_count > 0:
                        run.bugged_run = True
                        return
                    else:
                        shield_count += 1
                last_shield_time = Analyzer.time_from_line(line)

            elif any(True for shield_end in PTConstants.SHIELD_PHASE_ENDINGS.values() if shield_end in line):
                run.shield_phase_endings[phase] = Analyzer.time_from_line(line)
            
            # Leg kill
            elif PTConstants.LEG_KILL in line:
                legName = self.idLeg(line)
                run.legs[phase].append((legName, Analyzer.time_from_line(line)))

            elif PTConstants.BODY_VULNERABLE in line:  # Body vulnerable / phase 4 end
                if kill_sequence == 0:  # Only register the first invuln message on each phase
                    run.body_vuln[phase] = Analyzer.time_from_line(line)
                kill_sequence += 1  # 3x BODY_VULNERABLE in one phase means PT dies.
                if kill_sequence == 3 or (phase == 4 and run.bugged_run):  # PT dies.
                    run.body_kill[phase] = Analyzer.time_from_line(line)
                    run.final_time = Analyzer.time_from_line(line)
                    return
            elif PTConstants.STATE_CHANGE in line:  # Generic state change
                # Generic match on state change to find things we can't reliably find otherwise
                new_state = int(line.split()[8])
                # State 3, 5 and 6 are body kills for phases 1, 2 and 3.
                if new_state in [3, 5, 6]:
                    run.body_kill[phase] = Analyzer.time_from_line(line)
            elif PTConstants.PYLONS_LAUNCHED in line:  # Pylons launched
                run.pylon_start[phase] = Analyzer.time_from_line(line)
            elif PTConstants.PHASE_1_START in line:  # Profit-Taker found
                run.pt_found = Analyzer.time_from_line(line)
            elif PTConstants.PHASE_ENDS[phase] in line and phase != PTConstants.FINAL_PHASE:  # Phase endings minus p4
                if phase in [1, 3]:  # Ignore phase 2 as it already matches body_kill.
                    run.pylon_end[phase] = Analyzer.time_from_line(line)
                return
            else:
                pt_line_match = False

            if pt_line_match:
                run.final_time = Analyzer.time_from_line(line)
                continue

            # Non-pt specific messages
            if MiscConstants.NICKNAME in line:  # Nickname
                # Note: Replacing "î\x80\x80" has to be done since the Veilbreaker update botched names
                run.nickname = line.replace(',', '').replace("\ue000", "").split()[-2]
            elif MiscConstants.SQUAD_MEMBER in line:  # Squad member
                # Note: Replacing "î\x80\x80" has to be done since the Veilbreaker update botched names
                # Note: The characters might represent the player's platform
                run.squad_members.add(line.replace("\ue000", "").split()[-4])
            elif MiscConstants.ELEVATOR_EXIT in line:  # Elevator exit (start of speedrun timing)
                if not run.heist_start:  # Only use the first time that the zone is left aka heist is started.
                    run.heist_start = Analyzer.time_from_line(line)
                    Globals.LASTRUNTIME = run.heist_start
            elif MiscConstants.HEIST_START in line:  # New heist start found
                raise RunAbort(run, require_heist_start=False)
            elif MiscConstants.BACK_TO_TOWN in line or MiscConstants.ABORT_MISSION in line:
                # Save the run to convert it into a broken run.
                Globals.LASTBUGGEDRUN = run
                raise RunAbort(run, require_heist_start=True)
            elif MiscConstants.HOST_MIGRATION in line:  # Host migration
                raise RunAbort(run, require_heist_start=True)

    @staticmethod
    def time_from_line(line: str) -> float:
        return float(line.split()[0])

    @staticmethod
    def shield_from_line(line: str) -> tuple[DT, float]:
        return DT.from_internal_name(line.split()[-1]), Analyzer.time_from_line(line)

    @staticmethod
    def skip_until_one_of(log: Iterator[str], conditions: list[Callable[[str], bool]]) -> tuple[str, int]:
        try:
            line = next(log)
            while not any((condition(line) for condition in conditions)):  # Skip until one of the conditions hold
                line = next(log)
            return line, next((i for i, cond in enumerate(conditions) if cond(line)))  # return the first passing index
        except StopIteration:
            raise LogEnd()
