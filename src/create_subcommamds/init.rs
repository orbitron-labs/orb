use clap::Command;
use std::sync::Arc;
use toml::Value as TomlValue;

use crate::{config::load_config, CONFIG};

pub fn create_init_subcommands() -> Command {
    let mut command = Command::new("init")
        .about("Initializes a new orbit")
        .subcommand_required(true)
        .subcommand(
            Command::new("wallet")
                .about("Init a wallet")
                .arg_required_else_help(true)
                .arg(
                    clap::Arg::new("private-key")
                        .long("private-key")
                        .required(true),
                ),
        );

    unsafe {
        if CONFIG.is_none() {
            CONFIG = Some(Arc::new(load_config()));
        }
    }

    if let Some(config) = unsafe { CONFIG.as_ref() } {
        // Dynamically add subcommands to the "run" command
        if let Some(components) = config
            .get("components")
            .and_then(|components| components.get("init"))
        {
            if let TomlValue::Table(component_table) = components {
                for (component_name, component_config) in component_table.iter() {
                    let about = component_config
                        .get("about")
                        .and_then(|v| v.as_str())
                        .unwrap_or("");
                    let component_command = Command::new(component_name.as_str()).about(about);
                    command = command.subcommand(component_command)
                }
            }
        }
    }

    command
}
