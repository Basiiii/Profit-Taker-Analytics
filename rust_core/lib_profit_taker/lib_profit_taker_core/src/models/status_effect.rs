//! This module defines the `StatusEffect` enum, which represents various status effects that can be applied in the application.
//! A `StatusEffect` is used to categorize different types of effects, such as damage types or environmental effects.

/// Represents a status effect that can be applied in the application.
///
/// The `StatusEffect` enum is used to categorize different types of effects, such as damage types or environmental effects.
/// Each variant represents a specific type of status effect.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum StatusEffect {
    /// Impact damage type.
    Impact,

    /// Puncture damage type.
    Puncture,

    /// Slash damage type.
    Slash,

    /// Heat damage type.
    Heat,

    /// Cold damage type.
    Cold,

    /// Electric damage type.
    Electric,

    /// Toxin damage type.
    Toxin,

    /// Blast damage type.
    Blast,

    /// Radiation damage type.
    Radiation,

    /// Gas damage type.
    Gas,

    /// Magnetic damage type.
    Magnetic,

    /// Viral damage type.
    Viral,

    /// Corrosive damage type.
    Corrosive,
    
    /// No shield status effect, for when a shield is not present.
    NoShield,
}

impl StatusEffect {
    /// Converts a `StatusEffect` variant into its string representation.
    ///
    /// # Returns
    ///
    /// A string slice (`&str`) representing the name of the `StatusEffect` variant.
    ///
    /// # Examples
    ///
    /// ```
    /// use models::status_effect::StatusEffect;
    ///
    /// let effect = StatusEffect::Heat;
    /// assert_eq!(effect.to_string(), "Heat");
    /// ```
    #[must_use] pub const fn to_string(&self) -> &str {
        match *self {
            Self::Impact => "Impact",
            Self::Puncture => "Puncture",
            Self::Slash => "Slash",
            Self::Heat => "Heat",
            Self::Cold => "Cold",
            Self::Electric => "Electric",
            Self::Toxin => "Toxin",
            Self::Blast => "Blast",
            Self::Radiation => "Radiation",
            Self::Gas => "Gas",
            Self::Magnetic => "Magnetic",
            Self::Viral => "Viral",
            Self::Corrosive => "Corrosive",
            Self::NoShield => "No Shield",
        }
    }
}
