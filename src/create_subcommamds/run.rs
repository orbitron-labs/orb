use clap::Command;
use std::sync::Arc;
use toml::Value as TomlValue;

use crate::{config::load_config, CONFIG};

pub fn create_run_subcommands() -> Command {
    let mut run_command = Command::new("run")
        .about("Run an orbit")
        .subcommand_required(true);

    unsafe {
        if CONFIG.is_none() {
            CONFIG = Some(Arc::new(load_config()));
        }
    }

    if let Some(config) = unsafe { CONFIG.as_ref() } {
        // Dynamically add subcommands to the "run" command
        if let Some(components) = config
            .get("components")
            .and_then(|components| components.get("run"))
        {
            if let TomlValue::Table(component_table) = components {
                for (component_name, component_config) in component_table.iter() {
                    let about = component_config
                        .get("about")
                        .and_then(|v| v.as_str())
                        .unwrap_or("");
                    let mut component_command = Command::new(component_name.as_str())
                        .about(about)
                        .subcommand_required(true);

                    if let TomlValue::Table(subcomponent_table) = component_config {
                        for (subcomponent_name, subcomponent_config) in subcomponent_table.iter() {
                            if subcomponent_name != "about" {
                                let about = subcomponent_config
                                    .get("about")
                                    .and_then(|v| v.as_str())
                                    .unwrap_or("");
                                let subcomponent_command =
                                    Command::new(subcomponent_name.as_str()).about(about);
                                component_command =
                                    component_command.subcommand(subcomponent_command)
                            }
                        }
                    }

                    run_command = run_command.subcommand(component_command)
                }
            }
        }
    }

    run_command
}
