//! This library defines the shared models used across different parts of the application.
//! These models represent the core data structures that interact with the database and other components.
//! The goal is to provide a unified, consistent set of models for efficient data handling.

#![warn(clippy::nursery, clippy::pedantic)]

mod models;
pub use models::{Run, Phase, SquadMember, TotalTimes, ShieldChange, LegBreak, StatusEffect, LegPosition};
