use dirs::home_dir;
use std::{
    io::{BufRead, BufReader},
    process::{Command, Stdio},
};

pub fn execute_update_command() {
    let script_path = "~/orb-p/install.sh";
    // let script_path = home_dir()
    //     .expect("Failed to determine the user's home directory")
    //     .join(".orb/config.toml");

    // Run the shell script and capture its output in real-time
    let mut cmd = Command::new("sh")
        .arg("-c")
        .arg(script_path)
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
}
