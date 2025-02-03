//! This library is responsible for parsing and processing log files into structured, usable data.
//! It serves as the core component for handling Warframe log files, which are used to extract relevant information 
//! and make it accessible for further analysis or processing.
//!
//! The primary focus of this library is the parsing of log entries, transforming raw log data into meaningful data structures.
//! It includes various modules for different aspects of the log parsing process:
//!
//! - **parser_state**: Manages and tracks the state of the log parser during execution.
//! - **cli**: Provides command-line interface functionality for interacting with the parser, such as configuration or execution.
//! - **constants**: Contains environment-specific constants, such as paths to the log file and environment variables.
//! - **line_utils**: Utility functions for working with individual log lines or entries, including filtering and formatting.
//! - **parser**: Contains the main logic for parsing log entries and performing the core analysis on the log data.
//! - **parser_initializer**: Provides the functionality to initialize and spawn the log parser in a separate thread asynchronously.
//!
//! This library is designed to be flexible, efficient, and modular, allowing easy extension or modification as needed.
//! The different modules work together to provide a full solution for managing, parsing, and handling log files, 
//! with an emphasis on error handling, scalability, and maintainability.

#![warn(clippy::nursery, clippy::pedantic)]

mod parser_state;       // Module for managing the parser's state.
pub mod cli;            // Command-line interface functionalities.
pub mod constants;      // Constant values for paths and environment variables.
pub mod line_utils;     // Utilities for working with log lines.
pub mod parser;         // Main parser logic for log entries.
pub mod parser_initializer; // Module to initialize and spawn the log parser asynchronously.

pub use parser_initializer::initialize_parser; // Re-exporting `initialize_parser` for easy access.
