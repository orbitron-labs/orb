use dirs::home_dir;
use std::fs::File;
use std::io::Write;
use std::io::{Read, Result as FileResult};

pub fn create_and_save_wallet(content: &str) -> Result<(), std::io::Error> {
    // Get the user's home directory and construct the file path
    let mut file_path = home_dir().ok_or(std::io::Error::new(
        std::io::ErrorKind::NotFound,
        "Home directory not found",
    ))?;

    file_path.push(".orb"); // Create the .orb directory
    std::fs::create_dir_all(&file_path)?; // Create the directory if it doesn't exist

    file_path.push("wallet.pem"); // Add the file name to the path

    // Open the file in write mode and save "hello orbitron"
    let mut file = File::create(&file_path)?;

    // Write the content to the file
    file.write_all(content.as_bytes())?;

    println!("Wallet created and saved at: {:?}", file_path);

    Ok(())
}

pub fn read_wallet_file() -> FileResult<Option<String>> {
    // Get the user's home directory and construct the file path
    let mut file_path = home_dir().ok_or(std::io::Error::new(
        std::io::ErrorKind::NotFound,
        "Home directory not found",
    ))?;

    file_path.push(".orb"); // Navigate to the .orb directory
    file_path.push("wallet.pem"); // Navigate to the wallet.pem file

    // Check if the file exists
    if !file_path.exists() {
        return Ok(None::<String>); // File doesn't exist
    }

    // Open the file in read mode and read its content into a string
    let mut file = File::open(&file_path)?;
    let mut content = String::new();
    file.read_to_string(&mut content)?;

    Ok(Some(content))
}
