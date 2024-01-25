import os
import sys
from collections import defaultdict
from math import nan, isnan
from statistics import median
from time import sleep
from typing import Iterator, Callable, Optional, Union

from flask import Flask, request
import threading
import json

from sty import rs, fg

from src.enums.damage_types import DT
from src.exceptions.bugged_run import BuggedRun
from src.exceptions.log_end import LogEnd
from src.exceptions.run_abort import RunAbort
from src.utils import color, time_str, oxfordcomma


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


class MiscConstants:
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
                 nickname: str,
                 squad_members: set[str],
                 pt_found: float,
                 phase_durations: dict[int, float],
                 shield_phases: dict[float, list[tuple[DT, float]]],    # phase -> list((type, abs time))
                 legs: dict[int, list[float]],                          # phase -> list(abs time)
                 body_dur: dict[int, float],
                 pylon_dur: dict[int, float]):
        self.run_nr = run_nr
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

    def __str__(self):
        return '\n'.join((f'{key}: {val}' for key, val in vars(self).items()))

    @property
    def length(self):
        return self.phase_durations[4]

    @property
    def shield_sum(self) -> float:
        """Sum of shield times over all phases, excluding the nan values."""
        return sum(time for times in self.shield_phases.values() for _, time in times if not isnan(time))

    @property
    def leg_sum(self) -> float:
        """Sum of the leg times over all phases."""
        return sum(time for times in self.legs.values() for time in times)

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

    def pretty_print(self):
        print(color('-' * 72, fg.white))  # header

        self.pretty_print_run_summary()

        print(f'{fg.li_red}From elevator to Profit-Taker took {self.pt_found:.3f}s. '
              f'Fight duration: {time_str(self.length - self.pt_found, "units")}.\n')

        for i in [1, 2, 3, 4]:
            self.pretty_print_phase(i)

        self.pretty_print_sum_of_parts()

        print(f'{fg.white}{"-" * 72}\n\n')  # footer

    def pretty_print_run_summary(self):
        players = oxfordcomma([self.nickname] + list(self.squad_members - {self.nickname}))
        run_info = f'{fg.cyan}Profit-Taker Run #{self.run_nr} by {fg.li_cyan}{players}{fg.cyan} cleared in ' \
                   f'{fg.li_cyan}{time_str(self.length, "units")}'
        if self.best_run:
            run_info += f'{fg.white} - {fg.li_magenta}Best run!'
        elif self.best_run_yet:
            run_info += f'{fg.white} - {fg.li_magenta}Best run yet!'
        print(f'{run_info}\n')

    def pretty_print_phase(self, phase: int):
        white_dash = f'{fg.white} - '
        print(f'{fg.li_green}> Phase {phase} {fg.li_cyan}{time_str(self.phase_durations[phase], "brackets")}')

        if phase in self.shield_phases:
            shield_sum = sum(time for _, time in self.shield_phases[phase] if not isnan(time))
            shield_str = f'{fg.white} | '.join((f'{fg.li_yellow}{s_type} {"?" if isnan(s_time) else f"{s_time:.3f}"}s'
                                                for s_type, s_time in self.shield_phases[phase]))
            print(f'{fg.white} Shield change:\t{fg.li_green}{shield_sum:7.3f}s{white_dash}{fg.li_yellow}{shield_str}')

        normal_legs = [f'{fg.li_yellow}{time:.3f}s' for time in self.legs[phase][:4]]
        leg_regen = [f'{fg.red}{time:.3f}s' for time in self.legs[phase][4:]]
        leg_str = f"{fg.white} | ".join(normal_legs + leg_regen)
        print(f'{fg.white} Leg break:\t{fg.li_green}{sum(self.legs[phase]):7.3f}s{white_dash}{leg_str}')
        print(f'{fg.white} Body killed:\t{fg.li_green}{self.body_dur[phase]:7.3f}s')

        if phase in self.pylon_dur:
            print(f'{fg.white} Pylons:\t{fg.li_green}{self.pylon_dur[phase]:7.3f}s')

        if phase == 3 and self.shield_phases[3.5]:  # Print phase 3.5
            print(f'{fg.white} Extra shields:\t\t   {fg.li_yellow}'
                  f'{" | ".join((str(shield) for shield, _ in self.shield_phases[3.5]))}')
        print('')  # to print a newline

    def pretty_print_sum_of_parts(self):
        print(f'{fg.li_green}> Sum of parts {fg.li_cyan}{time_str(self.sum_of_parts, "brackets")}')
        print(f'{fg.white} Shield change:\t{fg.li_green}{self.shield_sum:7.3f}s')
        print(f'{fg.white} Leg Break:\t{fg.li_green}{self.leg_sum:7.3f}s')
        print(f'{fg.white} Body Killed:\t{fg.li_green}{self.body_sum:7.3f}s')
        print(f'{fg.white} Pylons:\t{fg.li_green}{self.pylon_sum:7.3f}s')

    def to_json(self):
        runFormat = Analyzer.get_run_format()
        
        pass
        


class AbsRun:

    def __init__(self, run_nr: int):
        self.run_nr = run_nr
        self.nickname = ''
        self.squad_members: set[str] = set()
        self.heist_start = 0.0
        self.pt_found = 0.0
        self.shield_phases: dict[float, list[tuple[DT, float]]] = defaultdict(list)  # phase -> list((type, abs time))
        self.shield_phase_endings: dict[int, float] = defaultdict(float)  # phase -> abs time
        self.legs: dict[int, list[float]] = defaultdict(list)  # phase -> list(absolute time)
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
            if len(self.legs[phase]) > 8:
                print(color(f'{len(self.legs[phase])} leg kills were recorded for phase {phase}.\n'
                            f'If you have a recording of this run and the fight indeed bugged out, please '
                            f'report the bug to Warframe.\n'
                            f'If you think the bug is with the analyzer, contact the creator of this tool instead.',
                            fg.li_red))

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
                if phase not in self.pylon_end:
                    failure_reasons.append(f'No pylon phase end time was recorded in phase {phase}.')

        if failure_reasons:
            raise BuggedRun(self, failure_reasons)
        # Else: return none implicitly

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
                    shield_phases[phase].append((shield_type, shield_end - previous_timestamp))
                    previous_timestamp = shield_end
                # The time of the final shield is determined by the shield_end transmission
                shield_phases[phase].append((self.shield_phases[phase][-1][0],
                                             self.shield_phase_endings[phase] - previous_timestamp))
                previous_timestamp = self.shield_phase_endings[phase]
            # Every phase has an armor phase
            for leg in self.legs[phase]:
                legs[phase].append(leg - previous_timestamp)
                previous_timestamp = leg
            body_dur[phase] = self.body_kill[phase] - self.body_vuln[phase]
            previous_timestamp = self.body_kill[phase]

            if phase in [1, 3]:  # Phases with pylon phases
                pylon_dur[phase] = self.pylon_end[phase] - self.pylon_start[phase]
                previous_timestamp = self.pylon_end[phase]

            # Set phase duration
            phase_durations[phase] = previous_timestamp - self.heist_start

        # Set phase 3.5 shields (possibly none on very fast runs)
        shield_phases[3.5] = [(shield, nan) for shield, _ in self.shield_phases[3.5]]

        return RelRun(self.run_nr, self.nickname, self.squad_members, pt_found,
                      phase_durations, shield_phases, legs, body_dur, pylon_dur)

    @property
    def failed_run_duration_str(self):
        if self.final_time is not None and self.heist_start is not None:
            return f'{fg.cyan}If Profit-Taker was killed, the run likely lasted around ' \
                   f'{fg.li_cyan}{time_str(self.final_time - self.heist_start, "units")}.\n'
        return ''


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
        
        @app.route("/last_run", methods= ['GET'])
        def last_run():
            """Return the last run that was logged.

            Returns:
                dict: The last run that was logged.
            """
            return self.lastRun
        
        @app.route("/healthcheck", methods= ['GET'])
        def healthcheck():
            """Return the status of the parser.

            Returns:
                dict: the status of the parser.
            """
            return {'status': 'ok'}
        
        @app.route("/post_run", methods = ['POST'])
        def post_run():
            """Store the latest completed run

            Returns:
                response: OK
            """
            self.lastRun = request.json

            return json.dumps({'success':True}), 200, {'ContentType':'application/json'} 

        try:
            threading.Thread(target=lambda: app.run(debug=True, use_reloader=False)).start()
        except Exception as e:
            print(e)

    def get_run_format(self):
        return self.runFormat

    def run(self):
        self.initAPI()


        with open("json/run_format.json") as file:
            self.runFormat = json.load(file)

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
            print(fr"{fg.li_grey}Opening Warframe's default log from %LOCALAPPDATA%/Warframe/EE.log in follow mode.")
            print('Follow mode means that runs will appear as you play. '
                  'The first shield will also be printed when Profit-Taker spawns.')
            print('Note that you can analyze another file by dragging it into the exe file.')
            self.follow_mode = True
            try:
                return os.getenv('LOCALAPPDATA') + r'/Warframe/EE.log'
            except TypeError:
                print(f'{fg.li_red}Hi there Linux user! Check the README on github.com/revoltage34/ptanalyzer or '
                      f'idalon.com/pt to find out how to get follow mode to work.')
                print(f'{rs.fg}Press ENTER to exit...')
                input()  # input(prompt) doesn't work with color coding, so we separate it from the print.
                exit(-1)

    @staticmethod
    def follow(filename: str):
        """generator function that yields new lines in a file"""
        known_size = os.stat(filename).st_size
        with open(filename, 'r', encoding='latin-1') as file:
            # Start infinite loop
            cur_line = []  # Store multiple parts of the same line to deal with the logger committing incomplete lines.
            while True:
                if (new_size := os.stat(filename).st_size) < known_size:
                    print(f'{fg.white}Restart detected.')
                    file.seek(0)  # Go back to the start of the file
                    print('Successfully reconnected to ee.log. Now listening for new Profit-Taker runs.')
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
        with open(dropped_file, 'r', encoding='latin-1') as it:
            try:
                require_heist_start = True
                while True:
                    try:
                        run = self.read_run(it, len(self.runs) + 1, require_heist_start).to_rel()

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

        # Display all runs
        if len(self.runs) > 0:
            for run in self.runs:
                if isinstance(run, RelRun):
                    run.pretty_print()
                else:  # Aborted or bugged run, just print the exception
                    print(run)

            if len(self.proper_runs) > 0:
                self.print_summary()
        else:
            print(f'{fg.white}No valid Profit-Taker runs found.\n'
                  f'Note that you have to be host throughout the entire run for it to show up as a valid run.')

        print(f'{rs.fg}Press ENTER to exit...')
        input()  # input(prompt) doesn't work with color coding, so we separate it in a print and an empty input.

    def follow_log(self, filename: str):
        it = Analyzer.follow(filename)
        best_time = float('inf')
        require_heist_start = True
        while True:
            try:
                run = self.read_run(it, len(self.runs) + 1, require_heist_start).to_rel()
                # TODO convert run to proper format, send to API
                self.runs.append(run)
                self.proper_runs.append(run)
                require_heist_start = True

                if run.length < best_time:
                    best_time = run.length
                    run.best_run_yet = True
                run.pretty_print()
                self.print_summary()
            except RunAbort as abort:
                print(abort)
                self.runs.append(abort)
                require_heist_start = abort.require_heist_start
            except BuggedRun as buggedRun:
                print(buggedRun)  # Print reasons why the run failed
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

    def register_phase(self, log: Iterator[str], run: AbsRun, phase: int) -> None:
        """
        Registers information to `self` for the current phase based on the information found in the logs.
        """
        kill_sequence = 0
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

                # The first shield can help determine whether to abort.
                if self.follow_mode and len(run.shield_phases[1]) == 1:
                    print(f'{fg.white}First shield: {fg.li_cyan}{run.shield_phases[phase][0][0]}')
            elif any(True for shield_end in PTConstants.SHIELD_PHASE_ENDINGS.values() if shield_end in line):
                run.shield_phase_endings[phase] = Analyzer.time_from_line(line)
            elif PTConstants.LEG_KILL in line:  # Leg kill
                run.legs[phase].append(Analyzer.time_from_line(line))
            elif PTConstants.BODY_VULNERABLE in line:  # Body vulnerable / phase 4 end
                if kill_sequence == 0:  # Only register the first invuln message on each phase
                    run.body_vuln[phase] = Analyzer.time_from_line(line)
                kill_sequence += 1  # 3x BODY_VULNERABLE in one phase means PT dies.
                if kill_sequence == 3:  # PT dies.
                    run.body_kill[phase] = Analyzer.time_from_line(line)
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
                run.nickname = line.replace(',', '').replace("î\x80\x80", "").split()[-2]
            elif MiscConstants.SQUAD_MEMBER in line:  # Squad member
                # Note: Replacing "î\x80\x80" has to be done since the Veilbreaker update botched names
                # Note: The characters might represent the player's platform
                run.squad_members.add(line.replace("î\x80\x80", "").split()[-4])
            elif MiscConstants.ELEVATOR_EXIT in line:  # Elevator exit (start of speedrun timing)
                if not run.heist_start:  # Only use the first time that the zone is left aka heist is started.
                    run.heist_start = Analyzer.time_from_line(line)
            elif MiscConstants.HEIST_START in line:  # New heist start found
                raise RunAbort(run, require_heist_start=False)
            elif MiscConstants.BACK_TO_TOWN in line or MiscConstants.ABORT_MISSION in line:
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

    def print_summary(self):
        assert len(self.proper_runs) > 0
        best_run = min(self.proper_runs, key=lambda run: run.length)
        print(f'{fg.li_green}Best run:\t\t'
              f'{fg.li_cyan}{time_str(best_run.length, "units")} '
              f'{fg.cyan}(Run #{best_run.run_nr})')
        print(f'{fg.li_green}Median time:\t\t'
              f'{fg.li_cyan}{time_str(median(run.length for run in self.proper_runs), "units")}')
        print(f'{fg.li_green}Median fight duration:\t'
              f'{fg.li_cyan}{time_str(median(run.length - run.pt_found for run in self.proper_runs), "units")}\n')
        print(f'{fg.li_green}Median sum of parts {fg.li_cyan}'
              f'{time_str(median(run.sum_of_parts for run in self.proper_runs), "brackets")}')
        print(f'{fg.white} Median shield change:\t{fg.li_green}'
              f'{median(run.shield_sum for run in self.proper_runs):7.3f}s')
        print(f'{fg.white} Median leg break:\t{fg.li_green}'
              f'{median(run.leg_sum for run in self.proper_runs):7.3f}s')
        print(f'{fg.white} Median body killed:\t{fg.li_green}'
              f'{median(run.body_sum for run in self.proper_runs):7.3f}s')
        print(f'{fg.white} Median pylons:\t\t{fg.li_green}'
              f'{median(run.pylon_sum for run in self.proper_runs):7.3f}s')
