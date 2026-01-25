// Import min-book and its appendices ambient
#import "@local/min-book:1.3.0": book, appendices

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
)

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
