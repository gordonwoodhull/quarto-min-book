# Proof-of-Concept Implementation of [min-book](https://typst.app/universe/package/min-book/) Typst book template for Quarto

This is a proof-of-concept implementation of a Quarto format extension implementing a Quarto book project using the Typst [min-book](https://typst.app/universe/package/min-book/) book template.

I don't intend to maintain this, so I am archiving it.

If you fork this, please share your maintained version:
- Submit to the [official Quarto extensions listing](https://github.com/quarto-dev/quarto-web/tree/main/docs/extensions/listings)
- Add it to [awesome-quarto](https://github.com/mcanouil/awesome-quarto/issues/new?assignees=mcanouil&labels=&template=suggestion.yml)

## Installation

```bash
quarto add gordonwoodhull/quarto-min-book
```

## Usage

In your `_quarto.yml`:

```yaml
project:
  type: book

format: min-book-typst
```

## Known Issues

The margin layout (using `reference-location: margin` and `citation-location: margin`) does not work well. Typst reports:

```
warning: layout did not converge within 5 attempts
 = hint: check if any states or queries are updating themselves
```

This would need help integrating Quarto's marginalia support with min-book's own margin handling.

## Requirements

- Quarto >= 1.9.18
- The `min-book` Typst package (automatically imported and bundled with [typst-gather](https://prerelease.quarto.org/docs/advanced/typst/typst-gather.html))

## Windows Users

The test directories use symlinks to the `_extensions` folder. On Windows, you may need to enable Developer Mode or run `git config --global core.symlinks true` before cloning.

## License

MIT
