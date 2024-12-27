# 8086 Serial Chat 📃

**8086 Serial Chat** is a bi-directional communication program written in 8086 Assembly language. It allows real-time text-based communication between two machines or terminals connected through the serial port (UART). The program splits the screen into two sections for input and output, simulating a basic "chat window."

## Features

- **Screen Division**: The display is divided into two sections:
  - **Top Section**: Your input (typed text).
  - **Bottom Section**: Received messages from the serial port.
- **Serial Communication**: Data is transmitted and received using UART (Universal Asynchronous Receiver/Transmitter).
- **Scrolling**: Automatically scrolls text when the screen reaches its limit.
- **Exit Option**: Press `ESC` to gracefully exit the program.

## Prerequisites

To run this program, you'll need the following:

1. **DOSBox-X**: A DOS emulator with enhanced features. Download it [here](https://dosbox-x.com/).
2. **Python**: To automate running the program.
3. A compatible assembler:
    - TASM (Turbo Assembler)
    - MASM (Microsoft Macro Assembler)

## Installation

1. **Clone the Repository**:

    ```bash
    git clone https://github.com/AhmedSobhy01/assembly-serial-chat.git
    cd assembly-serial-chat
    ```

2. **Set Up DOSBox-X**:

    - Ensure DOSBox-X is installed on your computer and its path is configured properly.

3. **Run the Program Using Python**:
   The provided `run.py` script will automate launching the program in DOSBox-X:

    ```bash
    python run.py
    ```

    This script assembles the code (if needed) and executes the program seamlessly in DOSBox-X.

## How It Works

- **Initialization**:

  - The program initializes the serial port for communication using standard UART configuration.
  - The screen is divided into two parts with a horizontal separator.

- **Chat Input and Output**:

  - **Input**: Type characters, which are transmitted to the connected terminal.
  - **Output**: Incoming characters are displayed in the lower section of the screen.

- **Scrolling**:

  - If text reaches the end of the screen, the program scrolls the display to keep the conversation flowing.

- **Exit**:
  - Press `ESC` to exit the program.

## Program Flowchart

```text
START
   │
   ├─► Clear Screen
   ├─► Draw Separator
   ├─► Initialize Serial Port
   │
   └─► MAIN LOOP
         ├─► Check for Incoming UART Data
         │    └─► Display Received Character
         │
         ├─► Check for Keyboard Input
         │    └─► Send Character to UART
         │
         └─► Check for Exit Command (ESC)
                 └─► EXIT
```

## Keyboard Controls

- **Type Text**: Sends the text to the other terminal.
- **Press `ESC`**: Exits the program.

## Customization

### Baud Rate

The current program is set to a baud rate divisor of `0x0C` for 9600 baud. Modify the following lines in `INIT_SERIAL` for other baud rates:

```assembly
MOV DX, 3F8h
MOV AL, 0Ch  ; LSB of baud rate divisor (0x0C = 9600 baud)
OUT DX, AL

MOV DX, 3F9h
MOV AL, 00h  ; MSB of baud rate divisor
OUT DX, AL
```

## Running with Python Script

The `run.py` script simplifies launching the program in **DOSBox-X**. Ensure the following:

1. DOSBox-X is installed and its executable is available in your system's PATH.
2. Run the script:

    ```bash
    python run.py
    ```

The script will assemble the program (if necessary) and open DOSBox-X to execute it.

## License

This project is released under the [MIT License](LICENSE).
