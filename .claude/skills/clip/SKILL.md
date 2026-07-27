---
name: clip
description: Copy output to the user's clipboard. Use when the user asks to copy or clip something just produced in the conversation.
allowed-tools: Bash, Write
---

## Instructions

### 1. Select content

Copy the deliverable the user refers to — the most recent substantive output unless they name something else — verbatim. Strip chat-only framing like "Here's the summary:". For code, omit the markdown fences.

### 2. Copy

Write the content to a temp file (session scratchpad if available), then pipe the file to the first available clipboard command:

- `pbcopy` (macOS), `clip.exe` (WSL/Windows), `wl-copy` (Wayland), `xclip -selection clipboard` or `xsel --clipboard --input` (X11)

If a `clip.exe` paste comes out with mangled characters, use `{ printf '\xff\xfe'; iconv -f UTF-8 -t UTF-16LE "${file}"; } | clip.exe` instead.

If no clipboard command exists (headless), just say so.

### 3. Confirm

Report in one line what was copied and its size, e.g. "Copied the plan (28 lines) to your clipboard".
