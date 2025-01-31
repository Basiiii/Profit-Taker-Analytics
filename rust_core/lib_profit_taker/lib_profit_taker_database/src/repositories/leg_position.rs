impl std::str::FromStr for LegPosition {
  type Err = String;

  fn from_str(s: &str) -> Result<Self, Self::Err> {
      match s {
          "FrontLeft" => Ok(LegPosition::FrontLeft),
          "FrontRight" => Ok(LegPosition::FrontRight),
          "BackLeft" => Ok(LegPosition::BackLeft),
          "BackRight" => Ok(LegPosition::BackRight),
          _ => Err(format!("Unknown leg position: {}", s)),
      }
  }
}