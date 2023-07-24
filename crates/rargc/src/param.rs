use std::collections::HashMap;

use crate::parser;

pub const EXTRA_ARGS: &str = "extra_args";

/// Stores the names of all the parameters.
pub type Names = (
    HashMap<String, parser::Position>,
    HashMap<char, parser::Position>,
);

/// A struct representin a param tag E.g. `@arg`, `@option`, `@flag`.
#[derive(Debug, Clone, Default)]
pub struct Data {
    pub name: String,
    pub choices: std::option::Option<Vec<String>>,
    pub multiple: bool,
    pub required: bool,
    pub default: std::option::Option<String>,
}

impl Data {
    pub fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            ..Default::default()
        }
    }
}

/// A parameter trait for the `@option`, `@flag`, and `@arg` tags.
pub trait Param {
    fn name(&self) -> &str;
    fn tag_name(&self) -> &str;
}

/// Represents a `@flag` param. E.g. `@flag -h --help "Prints help information"`
#[derive(Default, Debug, PartialEq, Eq, Clone)]
pub struct Flag {
    pub name: String,
    pub summary: String,
    pub short: std::option::Option<char>,
}

impl Flag {
    pub fn new(data: Data, summary: &str, short: std::option::Option<char>) -> Self {
        Self {
            name: data.name,
            summary: summary.to_string(),
            short,
        }
    }
}

impl Param for Flag {
    fn name(&self) -> &str {
        &self.name
    }

    fn tag_name(&self) -> &str {
        "@flag"
    }
}

/// Represents an `@option` param. E.g. `@option -n --name <name> "Your name"`
#[derive(Default, Debug, PartialEq, Eq, Clone)]
pub struct Option {
    pub name: String,
    pub summary: String,
    pub short: std::option::Option<char>,
    pub multiple: bool,
    pub required: bool,
    pub default: std::option::Option<String>,
    pub choices: std::option::Option<Vec<String>>,
    pub value_notation: std::option::Option<String>,
}

impl Option {
    pub fn new(
        data: Data,
        summary: &str,
        short: std::option::Option<char>,
        value_notation: std::option::Option<String>,
    ) -> Self {
        Self {
            name: data.name,
            summary: summary.to_string(),
            choices: data.choices,
            multiple: data.multiple,
            required: data.required,
            default: data.default,
            short,
            value_notation,
        }
    }
}
