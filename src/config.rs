use std::fs::File;
use std::io::Read;
use toml::Value as TomlValue;
use dirs::home_dir;

pub const API_ENDPOINT: &str = "http://57.151.52.101:8080";

pub fn load_config() -> TomlValue {
     // Specify the path to your config files
     let local_config_path = "local.config.toml";
     let orb_config_path = home_dir()
         .expect("Failed to determine the user's home directory")
         .join(".orb/config.toml");
 
     // Try to read the local config file first
     let mut config_content = String::new();
     if let Ok(mut file) = File::open(local_config_path) {
         file.read_to_string(&mut config_content)
             .expect("Failed to read local.config.toml");
     } else {
         // If local config file doesn't exist, read the orb config file
         let mut file = File::open(orb_config_path)
             .expect("Failed to open .orb/config.toml");
         file.read_to_string(&mut config_content)
             .expect("Failed to read .orb/config.toml");
     }
 
     // Parse the content of config.toml into a TomlValue
     toml::from_str(&config_content).expect("Failed to parse config.toml")
}
