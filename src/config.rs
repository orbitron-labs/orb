use std::fs::File;
use std::io::Read;
use toml::Value as TomlValue;

use dirs::home_dir;

pub fn load_config() -> TomlValue {
    // Specify the path to your config.toml file
    let config_path = "config.toml";
    // let config_path = home_dir()
    //     .expect("Failed to determine the user's home directory")
    //     .join("orb-p/config.toml");

    // Read the content of the config file
    let mut file = File::open(config_path).expect("Failed to open config.toml");
    let mut config_content = String::new();
    file.read_to_string(&mut config_content)
        .expect("Failed to read config.toml");

    // Parse the content of config.toml into a TomlValue
    let config: TomlValue = toml::from_str(&config_content).expect("Failed to parse config.toml");

    config
}
