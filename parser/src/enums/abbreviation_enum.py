from __future__ import annotations

from typing import TypeVar, Type, Optional
from aenum import MultiValueEnum

_T = TypeVar('_T')


class AbbreviationEnum(MultiValueEnum):
    """
    Adds a ``from_str`` method to ``MultiValueEnum`` that allows any of the string multivalues to map to the respective
    enumeration (case insensitive).

    The string Dunder method is overridden to show the value instead of the enum.
    """

    def __str__(self):
        return str(self.value)

    @classmethod
    def from_str(cls: Type[_T], name: str, default: _T = None) -> Optional[_T]:
        """
        Maps the given ``name`` (case insensitive) to the corresponding Enumeration type of ``cls``.\n
        :param name: The string that is matched on.
        :param default: The default value that is returned if no enumeration is matched.
        :return: The enumeration corresponding to name if it exists, default otherwise.
        """
        name = name.casefold()
        for enum_instance in iter(cls):
            for abbreviation in enum_instance.values:
                if name == abbreviation.casefold():
                    return enum_instance
        return default

    @classmethod
    def regex_match_any(cls) -> str:
        """
        Returns a regex to match any value recognized by ``cls``.\n
        :return: A string of all abbreviations in cls, separated by pipe | characters.
        """
        return "|".join((abbr for enum in iter(cls) for abbr in enum.values))
