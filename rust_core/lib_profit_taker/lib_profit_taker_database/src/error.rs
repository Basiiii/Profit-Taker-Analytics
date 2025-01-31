use thiserror::Error;

#[derive(Error, Debug)]
pub enum DataError {
    #[error("Database error: {0}")]
    Database(#[from] rusqlite::Error),
    
    #[error("Run not found")]
    NotFound,
    
    #[error("Invalid data format: {0}")]
    InvalidData(String),
}

pub type Result<T> = std::result::Result<T, DataError>;
