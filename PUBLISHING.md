# Publishing this extension to the Steam Workshop

Egosoft's `WorkshopTool` does the upload; the game itself has no upload path. The
mechanics were measured while publishing our first mod, and **`x4-mod-pause-on-load`'s
[`PUBLISHING.md`](https://github.com/mkoester/x4-mod-pause-on-load/blob/main/PUBLISHING.md)
is the long version** — Proton behaviour, the verbatim-packing proof, Egosoft's rules
and the sources. This file carries only what is specific to *this* mod, plus the steps
you cannot publish without.

## Prerequisites

- **Own X4 on Steam**, with Steam running and logged in.
- **Accept the Steam Workshop Legal Agreement** once, on the Steam website.
- **Install "X Tools"** — Steam app `282160`, `steam://install/282160`. It sits under
  *Tools* in the library, has no store page, and launching it opens a `cmd` shell at
  the Steam library root. It runs fine under Proton; Wine maps `Z:` to `/`, so Linux
  paths go in as `Z:\home\...`.

## ⚠ Publish from a clean staging copy, never the working tree

`-buildcat` packs *everything* under `-path`, and the tool uploads loose
`.txt`/`.pdf`/`.cur`/`.mkv` files beside the catalog. From this repo that would ship
`README.md`, `PUBLISHING.md`, `workshop-description.txt` and **`.git/`** to every
subscriber. Stage only what the game loads, plus `LICENSE`:

```sh
STAGE=../.publish/mk_save_sort_by_date        # gitignored in the workspace
rm -rf "$STAGE" && mkdir -p "$STAGE"
cp -r content.xml ui.xml ui LICENSE "$STAGE"/
```

The staging **folder name is the mod name** the tool uses, so it must read
`mk_save_sort_by_date`.

## Preview image

`preview.jpg` is in the repo root: 1920x1080, 266 KB — the Load Game menu with the
Date header active and the newest save on top, which shows the whole feature in one
frame. It is a 16:9 crop of a 3440x1440 ultrawide screenshot (`preview.png`, kept out
of git), taken from the left so the list stays at native resolution and stays legible
at thumbnail size.

Steam wants JPG or PNG, widescreen, 640x360 or larger, and caps the preview at 1 MB.
Root `.jpg` is one of the extensions `-buildcat` filters out, so it does not need
staging — `-preview` points at it in the repo, not in the staging copy.

## First publish

```
WorkshopTool publishx4 ^
  -path    "Z:\home\...\workspace_x4\.publish\mk_save_sort_by_date" ^
  -preview "Z:\home\...\workspace_x4\mk_save_sort_by_date\preview.jpg" ^
  -buildcat
```

Check `ext_01.cat` — a plain-text index, one line per packed file — before answering
`y` at the upload prompt. **Three** entries are expected: `LICENSE`, `ui.xml` and
`ui/mk_save_sort_by_date.lua`. `content.xml` is *not* among them: the catalog tool
excludes root-level `.xml` (`^[^/]*\.(xml|cat|dat|jpg|png)$`) and `WorkshopTool`
uploads it separately — its output says "in addition to content.xml". `ui.xml` is only
there because the tool adds an explicit `-include ui.xml`. Measured 2026-09-22 with
tool v1.15 / catalog tool v1.11.

The three sizes also sum to the byte size of `ext_01.dat`, which is a second check that
nothing else was packed.

**The item is created hidden.** Visibility is set on its web page afterwards, so a
first publish is safe to run and review; `WorkshopTool showpage` opens it.

## ⚠ Publishing rewrites `content.xml`

On a successful first publish the tool **replaces the `id` attribute** with the
Workshop id (`ws_<number>`) and adds `sync` and `lastupdate`. Later updates key on
that `id`, so the change must be committed:

```sh
git add content.xml && git commit -m "chore: record the Workshop id"
```

Measured on the sibling mod on 2026-09-21: it happened exactly as described, and the
rewritten file is what makes `WorkshopTool update` able to find the item again.

## After publishing

- Paste the BBCode from `workshop-description.txt` into the page by hand — subscribers
  read name and description from **Steam**, not from `content.xml`.
- The listing shows the **Steam account name** as the author, not `content.xml`'s
  `author` attribute.
- Add the Workshop link to `README.md` and record the `ws_` id in the workspace
  `AGENTS.md` Remotes section.

## Updating

```
WorkshopTool update ^
  -path "Z:\home\...\workspace_x4\.publish\mk_save_sort_by_date" ^
  -buildcat -changenote "what changed in this version"
```

`-changenote` is required. Bump `version` in `content.xml` first — the value is
**x100**, so `101` displays as v1.01.

## ⚠ Do not subscribe on a machine that develops this mod

Subscribers get the **folder name**, so a subscribed copy lands in
`extensions/mk_save_sort_by_date/` — and once the publish has rewritten `content.xml`,
the dev copy carries the subscribed copy's `id` as well. That is a clash on both axes.
The dev symlink therefore keeps a `_dev` suffix:

```sh
ln -s ~/Projects/workspace_x4/mk_save_sort_by_date \
      ~/.local/share/Steam/steamapps/common/"X4 Foundations"/extensions/mk_save_sort_by_date_dev
```

Two enabled copies would both write `saveSort`, which is harmless here — but X4 flags
the clash with `error="7"` and `x4prof status` reports `broken:`, so keep it to one.

## Folder name constraints

`a-z`, `0-9`, period, underscore, hyphen and space only; 32 characters maximum;
lowercased automatically. `mk_save_sort_by_date` is 20 characters and already
lowercase — which it must stay, since on Linux a mixed-case extension folder is
skipped in silence.
