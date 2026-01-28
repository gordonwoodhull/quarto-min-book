// Import min-book and its appendices ambient
#import "@preview/min-book:1.3.0": book, appendices

// Min-book structure: H1 = Parts, H2 = Chapters
// The filter shifts Quarto's headings to match this structure
#show: book.with(
$if(title)$
  title: [$title$],
$endif$
$if(by-author)$
  authors: "$for(by-author)$$it.name.literal$$sep$, $endfor$",
$endif$
  cover: none,
  titlepage: none,
  toc: false,
$if(margin-geometry)$
  // Pass book-aware margins that match marginalia's setup
  // This ensures min-book and marginalia use consistent margin values
  cfg: (
    margin: (
      inside: $margin-geometry.inner.far$ + $margin-geometry.inner.width$ + $margin-geometry.inner.separation$,
      outside: $margin-geometry.outer.far$ + $margin-geometry.outer.width$ + $margin-geometry.outer.separation$,
      top: $if(margin.top)$$margin.top$$else$1.25in$endif$,
      bottom: $if(margin.bottom)$$margin.bottom$$else$1.25in$endif$,
    ),
  ),
$endif$
)

$if(margin-geometry)$
// Configure marginalia page geometry AFTER book.with()
// IMPORTANT: This must come AFTER book.with() to override min-book's margin settings
// and ensure marginalia state is visible inside the book content
#import "@preview/marginalia:0.3.1" as marginalia

#show: marginalia.setup.with(
  inner: (
    far: $margin-geometry.inner.far$,
    width: $margin-geometry.inner.width$,
    sep: $margin-geometry.inner.separation$,
  ),
  outer: (
    far: $margin-geometry.outer.far$,
    width: $margin-geometry.outer.width$,
    sep: $margin-geometry.outer.separation$,
  ),
  top: $if(margin.top)$$margin.top$$else$1.25in$endif$,
  bottom: $if(margin.bottom)$$margin.bottom$$else$1.25in$endif$,
  book: true,
  clearance: $margin-geometry.clearance$,
)
$endif$

// Quarto uses custom figure kinds (quarto-float-fig, quarto-float-tbl, etc.)
// which don't match min-book's built-in numbering (kind:image, kind:table, kind:raw).
// Apply chapter-based numbering globally to all figures.
#set figure(numbering: figure-numbering)

// Min-book uses level-2 headings for chapters (H1=Parts, H2=Chapters)
// Reset figure/callout/equation counters at each chapter (level-2 heading)
// This supplements the level-1 resets that Quarto generates
#show heading.where(level: 2): it => {
  counter(figure.where(kind: "quarto-float-fig")).update(0)
  counter(figure.where(kind: "quarto-float-tbl")).update(0)
  counter(figure.where(kind: "quarto-float-lst")).update(0)
  counter(figure.where(kind: "quarto-callout-Note")).update(0)
  counter(figure.where(kind: "quarto-callout-Warning")).update(0)
  counter(figure.where(kind: "quarto-callout-Caution")).update(0)
  counter(figure.where(kind: "quarto-callout-Tip")).update(0)
  counter(figure.where(kind: "quarto-callout-Important")).update(0)
  counter(figure.where(kind: "quarto-float-dino")).update(0)
  counter(math.equation).update(0)
  // Note: appendix chapter counter is stepped by the Lua filter, not here
  // Theorem counters are handled by theorion with inherited-levels: 2
  it
}
