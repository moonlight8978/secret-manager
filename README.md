# Secret Manager

Encrypt/Decrypt personal sensitive data using AES-256-CBC

### Usage

```bash
bin/vs help
bin/vs help keygen
bin/vs help decrypt
bin/vs help encrypt
```

> The word `vs` stands for Victory's Secret (which has secret in its name)

### Run the demo

```bash
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAIiag8m0rmqupt1odk6AniVppg89Z3/eTdVf3Ur7xls moonlight8978@gmail.com" > ~/.ssh/moonlight.pub
cp .env.example .env # Remeber to reload env
bin/vs encrypt -d -k mYnXj79Ozf5Hl2ab4QAeqj7HI1LBG8pt7S9ZmQsaKJQ=
bin/vs decrypt -d -k mYnXj79Ozf5Hl2ab4QAeqj7HI1LBG8pt7S9ZmQsaKJQ=
```
