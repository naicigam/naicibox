<p align="center">
  <img src="logo.png" width="200" alt="Naicibox logo" />
</p>

**Naicibox** is my terminal-centric dev environment toolkit — modular, magical, and made to conjure complete setups with a single command.

 _“The magician’s toolkit — boxed and ready.”_

# Dev Config: Terminal-Centric Project Environment

A fully automated, reproducible, and modular development environment for terminal-focused workflows using **tmux**, **VS Code**, **Docker**, **Git**, and **Ansible**.

---

## 🎯 Goals

- 🧼 Clean project isolation (history, aliases, env vars)
- ⚡ Fast and keyboard-driven (tmux + Bash + Starship)
- 🧠 ChatGPT integration per project (via `aichat`)
- 🔐 Secure secret management with 1Password (`op`)
- 📦 Easy provisioning and scaling via Ansible
- 🛠 Language/tool-agnostic foundation (Python, C++, Docker, etc.)

---

## 🧰 Tools Used

| Tool         | Purpose                                  |
|--------------|-------------------------------------------|
| **tmux**     | Multi-window terminal sessions            |
| **Bash**     | Shell with per-project config             |
| **VS Code**  | Editor launched from project context      |
| **Docker**   | Containerized project environments        |
| **Starship** | Fast, minimal, informative prompt         |
| **aichat**   | Terminal ChatGPT window in each project   |
| **direnv**   | Auto-load environment vars per folder     |
| **Ansible**  | Setup and dotfile deployment automation   |
| **1Password CLI** | Secure secret injection (e.g., OpenAI key) |

---

## 🧩 Features

### ✅ Per-Project Isolation
- `.bashrc` with project-specific aliases and prompt
- `.bash_history` for isolated command logs
- `.envrc` to auto-load environment variables with `direnv`
- `tmux-layout.sh` to create named tmux sessions with windows:
  - Docker logs
  - Bash console
  - ChatGPT terminal (via `aichat`)
  - VS Code launch

### ✅ Ansible-Managed Setup
- Installs core tools: `git`, `tmux`, `curl`, `starship`, `aichat`, `direnv`
- Links dotfiles and helper scripts to the home directory
- Deploys a ready-to-copy `.template` for new projects

---

## 🚀 Usage

### 1. 🔧 Deploy Environment

1. Set the `PROJECTS_HOME` environment variable.

2. Run
```bash
ansible-playbook -i inventory playbook.yml
```

### 2. 🆕 Create a New Project

```bash
newproject myproject
project myproject
```

### 3. 🧠 Enable AI Assistant (if using aichat + 1Password)

```bash
cd $PROJECTS_HOME/myproject
direnv allow   # enables .envrc with env vars
```

---

## 📁 Project Template Structure

```
myproject/
├── .bashrc              # Project aliases, prompt
├── .bash_history        # Isolated history
├── .envrc               # direnv environment vars
├── start.sh             # Launches project tmux session
├── tmux-layout.sh       # Docker, console, aichat, VS Code
└── .vscode/             # (optional) editor config
```

---

## 📦 What's Included

- `playbook.yml` — top-level Ansible playbook
- `roles/` — modular tasks: dotfiles, tools, terminal, direnv, aichat
- `files/` — your `.bashrc`, `.bash_aliases`, and helper scripts
- `.template/` — reusable folder for new projects
- `bin/` — helper scripts: `project-start.sh`, `newproject`

---

## ✅ Clean, Extendable, Minimal

This setup is tuned for developers who:

- Prefer terminal-based workflows
- Use tmux + VS Code side-by-side
- Want full control and speed, without losing flexibility
