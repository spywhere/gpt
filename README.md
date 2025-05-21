# GPT (gpt)
A shell script for interacting with LLM models through chat completions. Battery included.

## Features

- Interactive chat session with attachment supported
- One-off chat completions
- Built-in prompts for one-liner code / shell command look up / URL lookup
- Built-in integration with git commit message hook / ZSH

## Supported Platform

- OpenRouter
- OpenAI
- Ollama
- LM Studio

## Requirements

- Bash
- `jq` - for interacting with JSON data
- `curl` - for making a request to OpenAI
- `base64` (optional) - for attachment processing
- `timg` (optional) - for displaying an image

## Get Started

Simply download `gpt` script file and make it executable, then you can trigger `gpt --help` to see how to use and some useful flags.

or you can simply use this shell command to download the script, put it under `/usr/local/bin` and make it executable.

```
curl -L https://github.com/spywhere/gpt/raw/main/gpt -o /usr/local/bin/gpt
chmod +x /usr/local/bin/gpt
```

Note: To update, simply re-download the script again

## Usage

We highly suggested to run the command with a `--help` flag to see all possible option you can adjusted.

### Generic Chat Completions

Run the command follows by the desired prompt of yours (mind the shell escapes), GPT should produced a response on your request.

```
gpt how much wood would a wood chuck chuck\? If a wood chuck could chuck wood.
```

Note: A chat completion is a one-off request

### Interactive Chat Session

Run the command with `--context` (or just `-c`) flag to enter an interactive session.
An optional context file path can be put in a flag (e.g., `--context=<filename>`) to store the conversations.

```
gpt -c you are a helpful assistant, help user fulfill their tasks
```

During the session, you can type `/help` or `/?` to view all available commands.

### A One-liner Code Search Engine

Run the command with a `--code` flag, follows by your desired behavior, GPT should produced a one-liner code on your request.

```
gpt --code function to check if a number is a prime number in js
```

### A Simple Command Line Search Engine

Run the command with a `--command` or `--cmd` flag, follows by your desired command prompt, GPT should produced a one-liner shell command on your request.

```
gpt --cmd prettify all json files in a current directory using jq
```

### A Quick URL Look Up

Run the command with a `--url` flag, follows by your desired lookup, GPT should produced an URL on your request.

```
gpt --url openai documentation on chat completions
```

## Debugging Prompt

GPT does have a hidden flag for debugging prompt, you can use one of the following flag to have GPT producing a debugging message to stderr.

- `--debug` Produce a body before sending a request and after receiving a response
- `--debug-dry` Produce a request body and terminate (does not sending any request)
