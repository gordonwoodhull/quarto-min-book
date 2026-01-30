# Proof-of-Concept Implementation of [min-book](https://typst.app/universe/package/min-book/) Typst book template for Quarto

This is a proof-of-concept implementation of a Quarto format extension implementing a Quarto book project using the Typst [min-book](https://typst.app/universe/package/min-book/) book template.

I don't intend to maintain this, so I am archiving it. If you fork this and want to be listed as a maintained fork, [contact me](mailto:gordon.woodhull@posit.co).

## Usage

In your `_quarto.yml`:

```yaml
project:
  type: book

format: min-book-typst
```

## Requirements

- Quarto >= 1.9.18
- The `min-book` Typst package (automatically imported and bundled with [typst-gather](https://prerelease.quarto.org/docs/advanced/typst/typst-gather.html))

## License

MIT
