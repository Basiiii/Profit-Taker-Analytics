from math import isnan
from typing import Iterable, Literal


def color(text: str, col: str) -> str:
    return col + text


def oxfordcomma(collection: Iterable[str]):
    collection = list(collection)
    if len(collection) == 0:
        return ''
    if len(collection) == 1:
        return collection[0]
    if len(collection) == 2:
        return collection[0] + ' and ' + collection[1]
    return ', '.join(collection[:-1]) + ', and ' + collection[-1]


def time_str(seconds: float, format_: Literal['brackets', 'units']) -> str:
    if isnan(seconds):
        return 'nan'
    if format_ == 'brackets':
        return f'[{int(seconds / 60)}:{int(seconds % 60):02d}]'
    elif format_ == 'units':
        if seconds < 60:
            return f'{int(seconds % 60)}s {int(seconds % 1 * 1000)}ms'
        else:
            return f'{int(seconds / 60)}m {int(seconds % 60):02d}s {int(seconds % 1 * 1000):03d}ms'
    raise ValueError(f"Expected format_ to be 'brackets' or 'units' but was {format_}.")
