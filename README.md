# GPT (gpt)
A shell script for interacting with OpenAI completions and chat completions API. Battery included

## Usage
We highly suggested to run the command with a `--help` flag to see all possible option you can adjusted.

### Generic Chat Completions
Run the command follows by the desired prompt of yours (mind the shell escapes), GPT should produced a response on your request.

```
gpt how much wood would a wood chuck chuck\? If a wood chuck could chuck wood.
```

Note: A chat completion is currently a one-off request, we are working on a support for an interactive session with a context.

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

## Requirements
- Bash or Zsh (we tried to make a script POSIX-compliance as much as possible)
- `jq` - for interacting with JSON data
- `curl` - for making a request to OpenAI

## Get Started
Simply download `gpt` script file and make it executable, then you can trigger `gpt --help` to see how to use and some useful flags.

or you can simply use this shell command to download the script, put it under `/usr/local/bin` and make it executable.

```
curl -L https://github.com/spywhere/gpt/raw/main/gpt -o /usr/local/bin/gpt
chmod +x /usr/local/bin/gpt
```

## Debugging Prompt
GPT does have a hidden flag for debugging prompt, you can use one of the following flag to have GPT producing a debugging message to stderr.

- `--debug` Produce a body before sending a request and after receiving a response
- `--debug-dry` Produce a request body and terminate (does not sending any request)
