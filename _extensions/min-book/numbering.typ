// Quarto-managed appendix state (min-book uses appendices ambient instead)
#let appendix-state = state("quarto-appendix", false)

// Track appendix chapter number with a counter (more reliable timing than state)
#let appendix-chapter-counter = counter("quarto-appendix-chapter")

// Helper to check appendix mode
#let in-appendix() = appendix-state.get()

// Min-book structure: H1 = Parts, H2 = Chapters
// So we need to get the second level of the heading counter for chapters
// In appendix mode, use our tracked appendix chapter counter
#let chapter-number() = {
  if in-appendix() {
    appendix-chapter-counter.get().first()
  } else {
    counter(heading).get().at(1, default: 0)
  }
}

// Chapter-based numbering for books with appendix support
// Note: min-book handles most numbering internally, these are for Quarto elements
// NOTE: Do NOT wrap in context {} - that breaks cross-chapter references
#let equation-numbering = it => {
  let in-appendix = appendix-state.get()
  let chapter = if in-appendix {
    appendix-chapter-counter.get().first()
  } else {
    counter(heading).get().at(1, default: 0)
  }
  let pattern = if in-appendix { "(A.1)" } else { "(1.1)" }
  numbering(pattern, chapter, it)
}

#let callout-numbering = it => {
  let in-appendix = appendix-state.get()
  let chapter = if in-appendix {
    appendix-chapter-counter.get().first()
  } else {
    counter(heading).get().at(1, default: 0)
  }
  let pattern = if in-appendix { "A.1" } else { "1.1" }
  numbering(pattern, chapter, it)
}

#let subfloat-numbering(n-super, subfloat-idx) = {
  let in-appendix = appendix-state.get()
  let chapter = if in-appendix {
    appendix-chapter-counter.get().first()
  } else {
    counter(heading).get().at(1, default: 0)
  }
  let pattern = if in-appendix { "A.1a" } else { "1.1a" }
  numbering(pattern, chapter, n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Min-book uses heading level 2 for chapters (H1 = Parts, H2 = Chapters)
// So we need inherited-levels: 2 to get proper chapter-based theorem numbering
#let theorem-inherited-levels = 2

// Appendix-aware theorem numbering
#let theorem-numbering(loc) = {
  if appendix-state.at(loc) { "A.1" } else { "1.1" }
}

// Theorem render function
// Note: brand-color is not available at this point in template processing
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  block(
    width: 100%,
    inset: (left: 1em),
    stroke: (left: 2pt + black),
  )[
    #if full-title != "" and full-title != auto and full-title != none {
      strong[#full-title]
      linebreak()
    }
    #body
  ]
}

// Chapter-based figure numbering for Quarto's custom float kinds
// Min-book's built-in numbering uses kind:image/table/raw, but Quarto uses
// kind:"quarto-float-fig"/"quarto-float-tbl"/etc, so we need to add rules for those
// NOTE: Do NOT wrap in context {} - that breaks cross-chapter references
// because Typst evaluates context at reference time, not definition time.
// Instead, let counter().get() be called directly in the numbering function.
#let figure-numbering(num) = {
  let in-appendix = appendix-state.get()
  let chapter = if in-appendix {
    appendix-chapter-counter.get().first()
  } else {
    counter(heading).get().at(1, default: 0)
  }
  let pattern = if in-appendix { "A.1" } else { "1.1" }
  numbering(pattern, chapter, num)
}
