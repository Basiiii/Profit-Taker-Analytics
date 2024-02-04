from __future__ import annotations

from typing import TYPE_CHECKING

from sty import fg

if TYPE_CHECKING:
    from src.analyzer import AbsRun


class BuggedRun(RuntimeError):
    """An exception indicating that a run has bugged out - it does not have
    enough information to convert to a relative run.

    If require_heist_start is set to True, the analyzer should look for a 'job start' line.
    Otherwise, the analyzer can assume that a new run started that aborted the old run."""
    def __init__(self, run: AbsRun, reasons: list[str]):
        self.run = run
        self.reasons = reasons

    def __str__(self):
        reason_str = '\n'.join(self.reasons)
        return f'{fg.li_red}Profit-Taker Run #{self.run.run_nr} was bugged, no stats will be displayed. ' \
               f'Bugs found:\n{reason_str}\n' \
               # f'{self.run.failed_run_duration_str}'
