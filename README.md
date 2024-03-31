# Orb: A Modular CLI Tool for Orbitron

Orb is a versatile command-line interface (CLI) tool designed to streamline interactions with Orbitron, offering a range of commands for deployment, execution, and initialization of orbits.

## Features

- **Deploy Orbits**: Easily deploy your orbits using the `deploy` command(coming soon).
- **Run Orbits**: Execute an existing orbit with the `run` command.
- **Initialize New Orbits**: Set up new orbits quickly using the `init` command.
- **Help & Support**: Access detailed help options with the `help` command.

## Quick Start

Run the installation command

```bash
  curl -L https://orbitron-labs.github.io/orb/install.sh
  orb run avail light node
```

## Getting Started

### Prerequisites

- Ensure you have [Rust](https://www.rust-lang.org/) installed on your machine.

### Installation

#### Build From Source

- Clone the repository:
  ```bash
  git clone https://github.com/orbitron-labs/orb.git
  ```
- Build the project:
  ```bash
  cd orb
  cargo build --release
  ```

### Usage

To use orb, navigate to the target directory and use the following commands:

- **Help**:
  ```bash
  ./target/release/orb -h
  ```

#### Commands

1. **Deploy an Orbit**:
   ```bash
   ./target/release/orb deploy
   ```
2. **Run an Orbit**:
   ```bash
   ./target/release/orb run
   ```
3. **Initialize a New Orbit**:
   ```bash
   ./target/release/orb init
   ```

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
