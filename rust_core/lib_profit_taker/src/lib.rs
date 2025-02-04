//! This library will be the public API.
//!
//! For example, where [`lib_profit_taker_parser`] might accept [`BufRead`], this library might
//! perform the responsibility of actually getting to `EE.log`, maybe alongside exposing direct
//! access to a [`BufRead`] function.

#![warn(clippy::nursery, clippy::pedantic)]
#![expect(
    unexpected_cfgs,
    reason = "flutter_rust_bridge bug <https://github.com/fzyzcjy/flutter_rust_bridge/issues/2493>"
)]

pub mod api;
#[allow(clippy::nursery, clippy::pedantic, reason = "generated code")]
mod frb_generated;
mod utils;