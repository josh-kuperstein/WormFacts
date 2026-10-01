<!-- TODO: banner image goes here, e.g. ![Worm Facts](docs/banner.png) -->

# Worm Facts

A World of Warcraft addon that answers unsolicited summon requests with a complimentary worm fact.

When someone whispers you "summ pls?", Worm Facts whispers back:

> Thank you for subscribing to Worm Facts!
>
> The bootlace worm may be the longest animal alive. A specimen that washed up in Scotland in 1864 was reported at 55 meters, longer than a blue whale, and it is about as thick as a shoelace.

It ships with more than 100 facts covering marine worms, parasites, anatomy, behavior, records, worms in culture and more. You won't see a repeat until every fact has been used, even across logouts.

## Installing

1. Download the latest `WormFacts-vX.Y.Z.zip` from the [Releases](../../releases) page.
2. Extract it into your client's AddOns folder, so you end up with `World of Warcraft/<client folder>/Interface/AddOns/WormFacts/`.
3. Restart the game or type `/reload`.

Worm Facts is turned on as soon as it loads.

## How it decides who gets a fact

Only whispers are checked. A whisper gets a reply if it contains one of your **trigger words**. Each trigger has a mode:

| Mode | Fires when | Example |
|---|---|---|
| Exact word | The whole word matches | `sum` matches "sum?" but not "summary" |
| Starts with | A word begins with the trigger | `summ` matches summon, summons, summy |
| Anywhere | The text appears anywhere, even mid-word | Use sparingly; this causes false alarms |

The defaults catch the usual spellings and typos, such as summon, summ, sum, sumn, smn and sumon.

Words on the **never trigger on** list are always ignored. This keeps "summer", "summit" and "summary" from earning a fact.

Each player gets at most one fact every 5 minutes by default. You can change this cooldown in the options. Replies are sent one at a time with a short gap, so a crowd of requests won't get you flagged by the server's spam filter.

## Options

Open the options panel with `/wf config`, or find it under **Options > AddOns > Worm Facts**. From there you can:

- Turn auto-replies on or off
- Set the per-person cooldown, with presets from Off to 1 hour
- Add, remove and change the mode of trigger words
- Edit the never-trigger list
- Type a sample whisper and see whether it would get a reply
- Preview a fact, or restore the default lists

Settings are shared by all your characters.

## Commands

| Command | What it does |
|---|---|
| `/wf` | Show status and a list of commands |
| `/wf config` | Open the options panel |
| `/wf on` / `/wf off` | Turn auto-replies on or off |
| `/wf test` | Print a fact to your own chat, without whispering anyone |
| `/wf match <text>` | Check whether a whisper would get a reply |
| `/wf cd <seconds>` | Set the per-person cooldown |
| `/wf add <word>` | Add an exact-word trigger |
| `/wf prefix <word>` | Add a starts-with trigger |
| `/wf remove <word>` | Remove a trigger |
| `/wf exclude <word>` | Never reply because of this word |
| `/wf list` | List the triggers and excluded words |
| `/wf stats` | Show how many requests you've answered |
| `/wf reset` | Clear the stats and start the fact cycle over |
| `/wf defaults` | Restore the default trigger and exclusion lists |
| `/wf debug` | Log every whisper with the reason it did or didn't get a reply |
| `/wf lint` | Check the facts for any that are too long to send |

`/wormfacts` works as well as `/wf`.

## Adding facts

Facts live in [Data/Facts.lua](Data/Facts.lua), grouped by category. Add a new string to any list, or make a new category, and the addon picks it up on the next `/reload`.

A few rules, also noted at the top of that file:

- **Keep each fact under 255 characters.** That's the most a single whisper can hold. Aim for 180 to 250. Run `/wf lint` to find any that are too long; the addon won't send them.
- **Use plain ASCII.** Curly quotes, em dashes and accented letters can come out garbled in chat.
- **Style:** name the animal, set up the hook, then deliver the payoff. Two sentences is usually right. Goofier is better.

## Compatibility

Worm Facts is built for the Forever client (versions 1.60.x), which uses the modern 12.x addon API. The interface numbers in `WormFacts.toc` follow the client version. To check yours, type:

```
/dump select(4, GetBuildInfo())
```

In some restricted content the client hides whisper text from addons. Worm Facts skips those whispers rather than guessing.

## Releasing

Releases are built by GitHub Actions. To publish one, set `## Version:` in `WormFacts.toc` to the new version, commit, then push a matching tag, such as `v3.6.1`. The workflow checks that the tag matches the TOC version, zips the addon and creates the GitHub release.
