impl std::str::FromStr for StatusEffect {
  type Err = String;

  fn from_str(s: &str) -> Result<Self, Self::Err> {
      match s {
          "Corrosive" => Ok(StatusEffect::Corrosive),
          "Magnetic" => Ok(StatusEffect::Magnetic),
          "Radiation" => Ok(StatusEffect::Radiation),
          // ... other variants
          _ => Err(format!("Unknown status effect: {}", s)),
      }
  }
}
