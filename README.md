# Installation

```bash
git clone git@github.com:hoxbro/dotfiles.git ~/dotfiles
```

```bash
git -C ~/dotfiles submodule update --init
```

```bash
stow -d ~/dotfiles -R . --no-folding
```

Use `--adopt` to overwrite existing files.

# Terminal

Font is `UbuntuMono Nerd Font 14`.

Foreground is ![#ffffff](https://placehold.co/15x15/ffffff/ffffff.png) `#ffffff` and background is ![#1a212e](https://placehold.co/15x15/1a212e/1a212e.png) `#1a212e`.

| Color   | Normal                                                             | Bright                                                             |
| ------- | ------------------------------------------------------------------ | ------------------------------------------------------------------ |
| Black   | ![#505354](https://placehold.co/15x15/505354/505354.png) `#505354` | ![#77767b](https://placehold.co/15x15/77767b/77767b.png) `#77767b` |
| Red     | ![#e01b24](https://placehold.co/15x15/e01b24/e01b24.png) `#e01b24` | ![#f66151](https://placehold.co/15x15/f66151/f66151.png) `#f66151` |
| Green   | ![#82b414](https://placehold.co/15x15/82b414/82b414.png) `#82b414` | ![#b7eb46](https://placehold.co/15x15/b7eb46/b7eb46.png) `#b7eb46` |
| Yellow  | ![#fd971f](https://placehold.co/15x15/fd971f/fd971f.png) `#fd971f` | ![#feed6c](https://placehold.co/15x15/feed6c/feed6c.png) `#feed6c` |
| Blue    | ![#268bd2](https://placehold.co/15x15/268bd2/268bd2.png) `#268bd2` | ![#62ade3](https://placehold.co/15x15/62ade3/62ade3.png) `#62ade3` |
| Magenta | ![#8c54fe](https://placehold.co/15x15/8c54fe/8c54fe.png) `#8c54fe` | ![#bfa0fe](https://placehold.co/15x15/bfa0fe/bfa0fe.png) `#bfa0fe` |
| Cyan    | ![#56c2d6](https://placehold.co/15x15/56c2d6/56c2d6.png) `#56c2d6` | ![#94d8e5](https://placehold.co/15x15/94d8e5/94d8e5.png) `#94d8e5` |
| White   | ![#ccccc6](https://placehold.co/15x15/ccccc6/ccccc6.png) `#ccccc6` | ![#f8f8f2](https://placehold.co/15x15/f8f8f2/f8f8f2.png) `#f8f8f2` |

# Maintenance

Run pre-commit hooks with:

```bash
pre-commit install
```
