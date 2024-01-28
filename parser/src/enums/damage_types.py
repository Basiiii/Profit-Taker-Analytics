from __future__ import annotations
from typing import Optional

from src.enums.abbreviation_enum import AbbreviationEnum


class DT(AbbreviationEnum):
    IMPACT = 'Impact', 'DT_IMPACT'
    PUNCTURE = 'Puncture', 'DT_PUNCTURE'
    SLASH = 'Slash', 'DT_SLASH'

    COLD = 'Cold', 'DT_FREEZE'
    HEAT = 'Heat', 'DT_FIRE'
    TOXIN = 'Toxin', 'DT_POISON'
    ELECTRICITY = 'Electricity', 'DT_ELECTRICITY'

    GAS = 'Gas', 'DT_GAS'
    VIRAL = 'Viral', 'DT_VIRAL'
    MAGNETIC = 'Magnetic', 'DT_MAGNETIC'
    RADIATION = 'Radiation', 'DT_RADIATION'
    CORROSIVE = 'Corrosive', 'DT_CORROSIVE'
    BLAST = 'Blast', 'DT_EXPLOSION'

    @property
    def internal_name(self) -> str:
        """Returns the name that is internally used at Digital Extremes."""
        return self.values[1]

    @staticmethod
    def from_internal_name(name: str) -> Optional[DT]:
        """
        Maps the given ``name`` (case sensitive) to the corresponding Enumeration.\n
        :param name: The internal name that is matched on.
        :return: The enumeration corresponding to name if it exists, default otherwise.
        """
        return next((enum_instance for enum_instance in iter(DT) if name == enum_instance.internal_name),
                    None)
