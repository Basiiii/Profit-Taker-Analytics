//! # Repositories Module  
//!  
//! This module serves as a container for various repository classes that manage database interactions
//! for different entities in the system. Each repository provides methods to query, insert, update, and
//! delete data related to a specific entity (e.g., runs, phases, squad members, etc.) within the `SQLite` database.
//!
//! ## Repositories Provided  
//! - **`RunRepository`**: Handles CRUD operations related to `run` entities.  
//! - **`PhaseRepository`**: Manages operations on `phase` entities, associated with specific runs.  
//! - **`SquadMemberRepository`**: Manages `squad_member` entities, which represent individual members of a squad.  
//! - **`ShieldChangeRepository`**: Handles operations on `shield_change` entities, tracking changes in shield states.  
//! - **`LegBreakRepository`**: Provides methods to interact with `leg_break` entities, associated with phases in a run.
//!
//! ## Usage Example
//! ```rust
//! use crate::repositories::{RunRepository, PhaseRepository};
//! use rusqlite::Connection;
//!
//! let conn = Connection::open("path_to_db").unwrap();
//!
//! // Create repositories
//! let run_repo = RunRepository::new(&conn);
//! let phase_repo = PhaseRepository::new(&conn);
//!
//! // Use repositories to interact with the database
//! let run = run_repo.get_run(1).unwrap();
//! let phases = phase_repo.get_for_run(1).unwrap();
//! ```

mod run_repo;
mod phase_repo;
mod squad_repo;
mod shield_change_repo;
mod leg_break_repo;
mod favorite_repo;

pub use run_repo::RunRepository;
pub use phase_repo::PhaseRepository;
pub use squad_repo::SquadMemberRepository;
pub use shield_change_repo::ShieldChangeRepository;
pub use leg_break_repo::LegBreakRepository;
pub use favorite_repo::FavoriteRepository;
