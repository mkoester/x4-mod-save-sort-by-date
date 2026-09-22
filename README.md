# Save Menu Sorted By Date — an X4: Foundations extension

Opens **Load Game** and **Save Game** already sorted by date, newest first,
instead of by savegame slot.

That is the whole mod. Three files, no dependencies, no settings, no UI of its
own — and nothing that Protected UI Mode restricts, so it works with protection
left on.

## What it actually changes

The base game keeps the sort order of those menus in a single field of its own
menu table (`ui/addons/ego_gameoptions/gameoptions.lua`):

```lua
local menu = {
	name = "OptionsMenu",
	…
	saveSort = "slot",
```

Six values exist — `slot`/`slot_inv`, `name`/`name_inv`, `date`/`date_inv`, one
pair per column header. This extension writes `"date"` into it at UI load. That
is all it does.

**Slot order, not name order, is the vanilla default.** It reads as name order
because the slot rows are labelled with the save names.

## What "by date" looks like, and why it is not just a reordering

In slot order the Load menu prints three blocks: quicksave, then up to three
autosaves, then the numbered slots in order. In date order all of those collapse
into **one** newest-first list, which is the point — the save you want is at the
top whether it came from a slot, an autosave or a quicksave.

(Vanilla 9.0x has ten slots and caps the autosave block at three — both are literal
constants in `gameoptions.lua`. A UI mod that substitutes that file can change them:
with kuertee's UI Extensions active there are twenty slots, as in `preview.jpg`.)

On the Save menu quicksave and autosaves are excluded (you cannot write to them)
and unused slots are appended after the list.

## The column headers still work

The value is written once, at UI load. Clicking **Slot** or **Name** changes it
for the rest of the session exactly as in vanilla; `date` comes back on the next
UI reload or game start.

Forcing the value on every menu open would break those buttons instead of
overriding them: they call `menu.refresh()`, which rebuilds the list through the
same code path that would re-assert it.

## How it works

| File | Role |
| --- | --- |
| `ui/mk_save_sort_by_date.lua` | finds `OptionsMenu` in the global `Menus` list, sets `saveSort` |
| `ui.xml` | declares the addon, with `<dependency name="ego_gameoptions"/>` for load order |
| `content.xml` | the manifest |

The menu table is reachable because `gameoptions.lua`'s `init()` inserts it into
the global `Menus` list, and `ego_detailmonitorhelper/helper.lua` publishes that
list with `MakeGlobalAvailable("Menus")`. The `<dependency>` is **load order, not
a feature dependency**: `ui/core/addon.xsd` states that an addon naming another
"will be loaded after the other addon", which is what guarantees `OptionsMenu` is
already registered when this file runs.

Nothing is written to disk. X4 has no config key for this sort order, so the
setting cannot persist across sessions without an options entry of its own.

## Install

The repository root *is* the extension, so there is nothing to extract:

```sh
X4="$HOME/.local/share/Steam/steamapps/common/X4 Foundations"
git clone https://github.com/mkoester/x4-mod-save-sort-by-date.git "$X4/extensions/mk_save_sort_by_date"   # target name matters on Linux
git -C "$X4/extensions/mk_save_sort_by_date" pull             # update
```

On Linux the folder name **must** be lowercase — a mixed-case extension directory
is skipped in silence, with no error anywhere.

## Publishing

[`PUBLISHING.md`](PUBLISHING.md) has the Steam Workshop steps — the short version of
the sibling mod's, with the staging copy and the preview-image requirement for this
mod. Not published yet.

## Licence

[MIT](LICENSE) — Copyright (c) 2026 Mirko Köster.
