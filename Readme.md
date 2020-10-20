# Clippy Assist

Clippy is back, and here to hang out with you in World of Warcraft!
He's draggable anywhere on your screen, and he'll do his best to be a
good friend. He can also display any text through a custom WeakAura
interface, as a simple custom action.

The addon has a number of slash commands, which can be viewed by typing
`/clippy -help`.

## Slash Commands

- `/clippy -help`: Lists all commands.
- `/clippy -hide`: Temporarily hide Clippy.
- `/clippy -show`: Show Clippy (if hidden).
- `/clippy -reset`: Resets Clippy's position.
- `/clippy -list`: Lists all available animations.
- `/clippy `{everything else}: Attempts to play that animation.

## WeakAura Support

A list of pre-made **sample WeakAuras can be found [here][3]**
on <span>Wago.io</span>.

Clippy can display any text, using the full power of any regular
WeakAura! This is accomplished with a custom Action.

1. In your desired WeakAura, go to the "Actions" tab.
2. Under the "On Show" category, check the "Custom" option.
3. Check that Clippy is loaded with `ClippyAssist.isReady()`.
4. Display text with `ClippyAssist.SetText(msg, duration)`.

It's that easy! `msg` can be any text you'd like to display,
and `duration` is counted in seconds.

Here's an example:

```lua
if ClippyAssist and ClippyAssist.isReady() then
	local message =
		"It looks like you're trying to write a letter." .. "\n" ..
		"Would you like some help with that?"
	ClippyAssist.SetText(message, 10.0)
end
```

----

*The project can be found on CurseForge [here][1].*

*Download the latest release from GitHub [here][2].*

*Premade WeakAuras are available from <span>Wago.io</span> [here][3].*

*All available animations can be viewed in [this Imgur gallery][4].*

*Latest CurseForge screenshots are [here][5].*

*A list of historical screenshots can be found in [this Imgur gallery][6].*

[1]: https://www.curseforge.com/wow/addons/clippy-assist
[2]: https://github.com/ErythroGuild/ClippyAssist/releases/latest
[3]: https://wago.io/uh00qHmL4
[4]: https://imgur.com/a/I6QzlrW
[5]: https://www.curseforge.com/wow/addons/clippy-assist/screenshots
[6]: https://imgur.com/a/vc5u7OI
