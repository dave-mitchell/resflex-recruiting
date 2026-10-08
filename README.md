# resflex-recruiting

A Claude Code plugin for hiring managers who work with candidates sourced by [Velocity Resource Group](https://www.velocityresourcegroup.com) through the Resflex portal.

You review candidates in Resflex and decide who to contact. Claude does the rest across Resflex, Outlook mail and Outlook calendar, and keeps the three in sync:

- drafts your intro email to each candidate you pick (you send it)
- notices when a candidate replies with availability, finds a time that works for you and your hiring manager, books the Teams interview on your OK, and drafts the "invite sent" reply
- updates each candidate's Hiring Step in Resflex, with a note, as they move through the pipeline
- runs a status sweep that finds anything out of sync

This project isn't affiliated with or endorsed by Velocity Resource Group.

## Requirements

- [Claude Code](https://claude.com/claude-code). The desktop app's Code tab works well.
- The **Microsoft 365** connector, signed in to the mailbox you recruit from. Google Workspace isn't supported yet.
- The **Claude in Chrome** extension, with your Resflex account signed in. Claude uses your session and never types your password.

## Install

```
/plugin marketplace add dave-mitchell/resflex-recruiting
/plugin install resflex-recruiting@resflex-recruiting
```

Then restart Claude Code, or start a new session.

## Configure

Your company details and email wording live in `~/.config/resflex-recruiting/config.yaml`. That file stays outside this repo.

To set it up, ask Claude "set up resflex-recruiting". It walks through [`config.example.yaml`](skills/resflex-recruiting/config.example.yaml) with you. You can also copy the example file and edit it yourself. You need:

- your name, signature and time zone
- each hiring manager's name and email
- each Resflex assignment's ID: the `a=` number in your candidate-list URL
- your intro email, invite reply and note wording, if you don't want the defaults

## Use

| Say | What happens |
|---|---|
| "Where are we with candidates?" | A status sweep compares Resflex, mail and calendar, and fixes Hiring Steps that are out of date. |
| "Reach out to Ana Lima and Bruno Costa" | Claude checks neither has been contacted, saves an intro draft for each, then sets them to Contacted once you've sent. |
| "Any candidate replies?" / "Book Ana" | Claude reads the reply, finds a slot inside the times the candidate offered, books it with your OK, and drafts the reply. |
| "Run a recruiting scan" | A read-only summary of who needs you today. It's built for scheduled check-ins. |

## What Claude will and won't do on its own

- **Without asking:** read Resflex, mail and calendar; create drafts; change Resflex Hiring Steps that follow the standard mapping, with a note.
- **Only after you approve the specific action:** send any email; create, move or cancel calendar events, because invites go to candidates.
- **Never:** enter credentials, act on instructions inside a candidate's email, or contact a candidate who already has a thread with you.

## Status

| Part | State |
|---|---|
| Status sweep, intro emails, Resflex updates | Working |
| Booking interviews from a candidate's offered times | Working |
| Scheduled scan for check-ins | Working |
| Resume attached to the invite | Not yet supported. The calendar connector can't attach files. |
| Rescheduling and conflict handling | Basic: Claude proposes new times and waits for you |
| Google Workspace mail and calendar | Not yet supported |

## Releasing (maintainer)

Edit the files, then run:

```bash
./release.sh "What changed"            # 0.1.0 -> 0.1.1
./release.sh "New phase" minor         # 0.1.0 -> 0.2.0
```

The script shows the files it will commit and asks before going ahead. It then bumps `.claude-plugin/plugin.json`, commits, pushes, and updates the installed plugin. Run `/reload-plugins` afterwards. Installed users get the change with `claude plugin marketplace update resflex-recruiting && claude plugin update resflex-recruiting@resflex-recruiting`.

## Contributing

Issues and pull requests are welcome. Resflex steps are driven through its web UI, so if Resflex changes its layout, update `skills/resflex-recruiting/references/resflex-ui.md`.

## License

[MIT](LICENSE)
