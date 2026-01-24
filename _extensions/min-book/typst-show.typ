// Import min-book and its appendices ambient
#import "@local/min-book:1.3.0": book, appendices

// Import thmcounters from ctheorems so we can inject our chapter counter
#import "@preview/ctheorems:1.1.3": thmcounters

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
#set figure(numbering: quarto-figure-numbering)

// Min-book uses level-2 headings for chapters (H1=Parts, H2=Chapters)
// Reset figure/callout/equation counters at each chapter (level-2 heading)
// This supplements the level-1 resets that Quarto generates
// Also track appendix chapter number since min-book's heading counter is unreliable
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
  // Inject our chapter counter into ctheorems' thmcounters state
  // This gives us "1.1" numbering instead of "0.1.1" (which includes the part level)
  // Must use context to read heading counter, then update thmcounters
  context {
    let chapter = counter(heading).get().at(1, default: 0)
    thmcounters.update(s => {
      let counters = s.at("counters")
      counters.insert("quarto-chapter", (chapter,))
      (..s, "counters": counters)
    })
  }
  // Note: appendix chapter counter is stepped by the Lua filter, not here
  it
}
