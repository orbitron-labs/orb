use std::{
    io::{BufRead, BufReader},
    process::{exit, Command, Stdio},
};
use serde_json::json;

use crate::config;
use crate::config::API_ENDPOINT;

pub fn execute_run_command(component_name: &str, subcomponent_name: &str) {
    // Load configuration using config::load_config function
    let config = config::load_config();

    // Access component configuration based on component_name and subcomponent_name
    let component_config = config
        .get("components")
        .and_then(|components| components.get("run"))
        .and_then(|components| components.get(component_name))
        .and_then(|component| component.get(subcomponent_name));

    match component_config {
        Some(subcomponent) => {
            let _binary = subcomponent
                .get("binary")
                .expect("Binary path not found")
                .as_str()
                .unwrap();
            let download_script = subcomponent
                .get("download")
                .expect("Download script not found")
                .as_str()
                .unwrap();

            // println!("Running {} with binary: {}", subcomponent_name, binary);
            // println!("Downloading using script: {}", download_script);

            // Execute the download script if provided
            if !download_script.is_empty() {
                // println!("Running shell script: {}", download_script);

                let payload = json!({
                    "orbit": format!("{}-{}", component_name, subcomponent_name),
                    "component_name": component_name,
                    "subcomponent_name": subcomponent_name,
                  });
  
                  // Create a new client object
                  let client = reqwest::blocking::Client::new();
  
                  // Send a POST request with the payload
                  let _response = client
                      .post(format!("{API_ENDPOINT}/save-orbit-run"))
                      .json(&payload)
                      .send()
                      .expect("Failed to send POST request");

                // Run the shell script and capture its output in real-time
                let mut cmd = Command::new("sh")
                    .arg("-c")
                    .arg(download_script)
                    .stdout(Stdio::piped())
                    .spawn()
                    .expect("Failed to execute download script");

                if let Some(stdout) = cmd.stdout.take() {
                    let reader = BufReader::new(stdout);
                    for line in reader.lines() {
                        if let Ok(line) = line {
                            println!("{}", line);
                        }
                    }
                }

                let status = cmd.wait().expect("Failed to wait for script completion");
                if status.success() {
                    println!("Download script executed successfully");
                } else {
                    println!(
                        "Download script failed with exit code: {}",
                        status.code().unwrap_or(1)
                    );
                }
            } else {
                println!("Download path not found in configuration.");
            }
        }
        None => {
            eprintln!("Component or subcomponent not found in config.toml");
            exit(1);
        }
    }
}
