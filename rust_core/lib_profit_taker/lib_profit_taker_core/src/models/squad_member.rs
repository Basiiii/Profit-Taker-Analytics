//! This module defines the `SquadMember` struct, which represents a member of a squad in a run.
//! A `SquadMember` contains the name of the squad member, which is used to identify them within the squad.

/// Represents a member of a squad in a run.
///
/// The `SquadMember` struct is used to store information about a squad member, specifically their name.
/// This is useful for tracking squad members.
#[derive(Debug)]
pub struct SquadMember {
    /// The name of the squad member.
    pub member_name: String,
}

impl SquadMember {
    /// Creates a new `SquadMember` instance with the specified name.
    ///
    /// # Arguments
    ///
    /// * `name` - The name of the squad member.
    ///
    /// # Returns
    ///
    /// A new `SquadMember` instance with the provided name.
    ///
    /// # Examples
    ///
    /// ```
    /// use models::squad_member::SquadMember;
    ///
    /// let member = SquadMember::new("Alice");
    /// assert_eq!(member.member_name, "Alice");
    /// ```
    pub fn new(name: &str) -> Self {
        SquadMember {
            member_name: name.to_string(),
        }
    }
}
