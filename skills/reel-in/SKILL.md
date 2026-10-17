---
name: reel-in
description: Pull any files (videos, photos, audio, assets, anything) from the Google Drive "Footage Inbox" folder onto this Mac and delete them from Drive. Use when the user says things like "reel in", "pull my footage", "grab my videos/images/assets from Drive", "I uploaded some files", or wants to start editing media they sent from their phone.
---

# reel-in

Moves every file of any type (videos, images, audio, project assets) in Google Drive's `Footage Inbox` folder to `~/Videos/Footage/<project>/` on this Mac, verifying each file before deleting it from Drive. Originals go to Drive's Trash, which Google empties after 30 days.

## Run it

```bash
~/.claude/skills/reel-in/reel-in.sh [project-name]
```

- `project-name` is optional. If the user names a project ("pull footage into launch-video"), pass it as a short kebab-case name. Otherwise omit it and the folder is today's date (`YYYY-MM-DD`).
- Running into an existing folder is fine; new files are added alongside.
- Run it with a long timeout (up to 10 minutes) or in the background: multi-GB videos take a while.

## After it runs

Report back briefly (the user is usually on their phone):
- The destination folder path.
- Each file with size, plus duration for video/audio or dimensions for images (the script prints these).
- Any warning about files left in the inbox.

Then offer to start editing with that folder as the source.

## If it fails

- `didn't find section in config file` or auth errors: the Drive login expired. Tell the user to run `rclone config reconnect gdrive:` at the Mac; it needs a browser click.
- `directory not found`: the `Footage Inbox` folder was renamed or deleted in Drive. Recreate it with `rclone mkdir "gdrive:Footage Inbox"`.
- Never delete local footage to retry; rclone only removes the Drive copy after a verified transfer.
