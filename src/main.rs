/*
Copyright © 2024 Orbitron Labs
*/

mod config;
mod create_subcommamds;
mod executor;
mod logo;
mod utils;

use clap::Command;
use config::load_config;

use logo::print_orb_logo;
use std::sync::Arc;
use toml::Value as TomlValue;

use create_subcommamds::{create_init_subcommands, create_run_subcommands};
use executor::{execute_init_command, execute_run_command};
use utils::create_and_save_wallet;

static mut CONFIG: Option<Arc<TomlValue>> = None;

fn main() {
    print_orb_logo();
    let _config = load_config();

    let mut app = Command::new("ORB CLI")
        .version("0.1.0")
        .author("Orbitron. contact@orbitron.sh")
        .about("A modular CLI tool for Orbitron")
        .subcommand_required(true)
        .subcommand(Command::new("update").about("Update the orb CLI"));

    // Get commands to app
    app = app.subcommand(create_run_subcommands());
    app = app.subcommand(create_init_subcommands());

    let matches = app.get_matches();

    match matches.subcommand_name() {
        Some("run") => {
            // Handle the "run" subcommand
            if let Some(component_matches) = matches.subcommand_matches("run") {
                let component_name = component_matches.subcommand_name().unwrap();
                println!("component_name {:?}", component_name);
                if let Some(subcomponent_matches) =
                    component_matches.subcommand_matches(component_name)
                {
                    let subcomponent_name = subcomponent_matches.subcommand_name().unwrap();
                    execute_run_command(component_name, subcomponent_name);
                }
            }
        }
        Some("init") => {
            // Handle the "init" subcommand
            if let Some(component_matches) = matches.subcommand_matches("init") {
                let component_name = component_matches.subcommand_name().unwrap();
                println!("component_name {:?}", component_name);
                if let Some(subcomponent_matches) = component_matches.subcommand_matches("wallet") {
                    let private_key = subcomponent_matches
                        .get_one::<String>("private-key")
                        .unwrap();
                    let _ = create_and_save_wallet(private_key);
                } else {
                    execute_init_command(component_name);
                }
            }
        }

        Some("update") => {
            // Handle the "version" subcommand
            executor::execute_update_command();
        }
        Some("version") => {
            // Handle the "version" subcommand
        }
        _ => {
            // Invalid or no subcommand provided
        }
    }
}
