// Quarto-managed appendix state (min-book uses appendices ambient instead)
#let quarto-appendix-state = state("quarto-appendix", false)

// Track appendix chapter number with a counter (more reliable timing than state)
#let quarto-appendix-chapter-counter = counter("quarto-appendix-chapter")

// Helper to check appendix mode
#let quarto-in-appendix() = quarto-appendix-state.get()

// Min-book structure: H1 = Parts, H2 = Chapters
// So we need to get the second level of the heading counter for chapters
// In appendix mode, use our tracked appendix chapter counter
#let quarto-chapter-number() = {
  if quarto-in-appendix() {
    quarto-appendix-chapter-counter.get().first()
  } else {
    counter(heading).get().at(1, default: 0)
  }
}

// Chapter-based numbering for books with appendix support
// Note: min-book handles most numbering internally, these are for Quarto elements
// NOTE: Do NOT wrap in context {} - that breaks cross-chapter references
#let quarto-equation-numbering = it => {
  let in-appendix = quarto-appendix-state.get()
  let chapter = if in-appendix {
    quarto-appendix-chapter-counter.get().first()
  } else {
    counter(heading).get().at(1, default: 0)
  }
  let pattern = if in-appendix { "(A.1)" } else { "(1.1)" }
  numbering(pattern, chapter, it)
}

#let quarto-callout-numbering = it => {
  let in-appendix = quarto-appendix-state.get()
  let chapter = if in-appendix {
    quarto-appendix-chapter-counter.get().first()
  } else {
    counter(heading).get().at(1, default: 0)
  }
  let pattern = if in-appendix { "A.1" } else { "1.1" }
  numbering(pattern, chapter, it)
}

#let quarto-subfloat-numbering(n-super, subfloat-idx) = {
  let in-appendix = quarto-appendix-state.get()
  let chapter = if in-appendix {
    quarto-appendix-chapter-counter.get().first()
  } else {
    counter(heading).get().at(1, default: 0)
  }
  let pattern = if in-appendix { "A.1a" } else { "1.1a" }
  numbering(pattern, chapter, n-super, subfloat-idx)
}

// Min-book uses heading level 2 for chapters
// ctheorems with base: "heading", base_level: 2 would give "part.chapter.theorem" (0.1.1)
// because min-book uses unnumbered parts at level 1.
//
// SOLUTION: We inject a custom "quarto-chapter" counter into ctheorems' internal
// thmcounters state. This counter contains just the chapter number (no part).
// Then we use base: "quarto-chapter" so ctheorems uses our clean counter.
//
// The thmcounters state is updated at each chapter heading (see typst-show.typ).
#let quarto-thmbox-args = (base: "quarto-chapter", base_level: 1)

// Chapter-based figure numbering for Quarto's custom float kinds
// Min-book's built-in numbering uses kind:image/table/raw, but Quarto uses
// kind:"quarto-float-fig"/"quarto-float-tbl"/etc, so we need to add rules for those
// NOTE: Do NOT wrap in context {} - that breaks cross-chapter references
// because Typst evaluates context at reference time, not definition time.
// Instead, let counter().get() be called directly in the numbering function.
#let quarto-figure-numbering(num) = {
  let in-appendix = quarto-appendix-state.get()
  let chapter = if in-appendix {
    quarto-appendix-chapter-counter.get().first()
  } else {
    counter(heading).get().at(1, default: 0)
  }
  let pattern = if in-appendix { "A.1" } else { "1.1" }
  numbering(pattern, chapter, num)
}
