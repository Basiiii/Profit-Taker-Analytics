from __future__ import annotations

from typing import TYPE_CHECKING

from src.utils import time_str

if TYPE_CHECKING:
    from src.analyzer import AbsRun


class RunAbort(Exception):
    """An exception indicating that a run has aborted.

    If require_heist_start is set to True, the analyzer should look for a 'job start' line.
    Otherwise, the analyzer can assume that a new run started that aborted the old run."""
    def __init__(self, run: AbsRun, *, require_heist_start: bool):
        self.run = run
        self.require_heist_start = require_heist_start

    def __str__(self):
        return f'Profit-Taker Run #{self.run.run_nr} was aborted or had bugged logs.\n' \
               # f'{self.run.failed_run_duration_str}'
