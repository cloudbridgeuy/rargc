use clap::Parser;
use color_eyre::eyre::{self, Result};

use rargc::commands;
use rargc::{Cli, SubCommands};

fn main() -> Result<()> {
    env_logger::init();
    color_eyre::install()?;

    let cli = Cli::parse();

    let result = match cli.command {
        Some(SubCommands::Tree(options)) => commands::tree::Command::new(options.into()).run(),
        Some(SubCommands::Build(options)) => commands::build::Command::new(options.into()).run(),
        None => Err(eyre::format_err!("No subcommand provided")),
    };

    if let Err(err) = result {
        log::error!("{}", err);
        std::process::exit(1);
    }

    Ok(())
}
