-- min-book.lua
-- Min-book-specific part and appendix handling for Typst books
--
-- Min-book structure (with parts enabled):
--   H1 = Parts
--   H2 = Chapters
--   H3+ = Sections
--
-- Quarto emits H1 for chapters, so we shift all non-part headings down by 1 level.
-- Parts (bookItemType == "part") stay at H1.
-- Appendices use min-book's #show: appendices ambient.

-- Track whether we've entered appendix mode (persists across the document)
local in_appendix_mode = false
local appendix_chapter_count = 0

-- Build counter reset commands dynamically from quarto.doc.crossref.categories
local function build_counter_resets()
  local lines = pandoc.List({})

  -- Iterate over all crossref categories to find figure kinds
  for _, category in ipairs(quarto.doc.crossref.categories.all) do
    if category.kind == "float" then
      -- Floats use "quarto-float-" .. ref_type (e.g., quarto-float-fig)
      lines:insert('counter(figure.where(kind: "quarto-float-' .. category.ref_type .. '")).update(0)')
    elseif category.kind == "Block" then
      -- Block kinds (callouts) use "quarto-callout-" .. name (e.g., quarto-callout-Warning)
      local callout_ref_types = {nte=true, wrn=true, cau=true, tip=true, imp=true}
      if callout_ref_types[category.ref_type] then
        lines:insert('counter(figure.where(kind: "quarto-callout-' .. category.name .. '")).update(0)')
      end
    end
  end

  -- Always reset math equation counter
  lines:insert('counter(math.equation).update(0)')

  return "#" .. table.concat(lines, "\n#")
end

local function is_typst_book()
  local file_state = quarto.doc.file_metadata()
  return quarto.doc.is_format("typst") and
         file_state ~= nil and
         file_state.file ~= nil
end

return {
  Header = function(el)
    local file_state = quarto.doc.file_metadata()

    if not is_typst_book() then
      return nil
    end

    -- For non-book files or files without metadata, just shift headings
    if file_state == nil or file_state.file == nil then
      -- Shift all headings down by 1 level for min-book structure
      el.level = el.level + 1
      return el
    end

    local file = file_state.file
    local bookItemType = file.bookItemType

    -- Handle parts: keep at H1 (min-book's part level)
    -- Parts are special - they stay at level 1
    -- Must emit with outlined: true for min-book's show rule to match
    -- (Pandoc converts .unnumbered to outlined: false, but min-book needs outlined: true)
    if el.level == 1 and bookItemType == "part" then
      return pandoc.RawBlock('typst',
        '#heading(level: 1, numbering: none, outlined: true)[' ..
        pandoc.utils.stringify(el.content) .. ']')
    end

    -- Handle appendices divider: start the appendices ambient
    if el.level == 1 and bookItemType == "appendix" then
      in_appendix_mode = true
      appendix_chapter_count = 0

      -- Update Quarto's appendix state for numbering
      local stateUpdate = pandoc.RawBlock('typst', '#quarto-appendix-state.update(true)')

      -- Reset the appendix chapter counter
      local counterReset = pandoc.RawBlock('typst', '#quarto-appendix-chapter-counter.update(0)')

      -- Start min-book's appendices ambient
      local appendicesStart = pandoc.RawBlock('typst', '#show: appendices')

      -- The divider is always unnumbered, just emit the ambient setup
      -- Note: figure counter resets are added by each appendix chapter's handling
      return {stateUpdate, counterReset, appendicesStart}
    end

    -- Handle chapters that come after the appendices divider
    if el.level == 1 and bookItemType == "chapter" and in_appendix_mode then
      appendix_chapter_count = appendix_chapter_count + 1

      -- Step the appendix chapter counter BEFORE the heading
      local counterStep = pandoc.RawBlock('typst', '#quarto-appendix-chapter-counter.step()')

      -- Reset figure/callout/equation counters for this appendix chapter.
      -- This is needed because the heading level shift (H1→H2) happens here in Lua,
      -- which means the show rule in typst-show.typ fires with wrong timing.
      -- The counter reset must happen BEFORE content, but show rules fire DURING display.
      -- Built dynamically from quarto.doc.crossref.categories (includes custom crossref types)
      local counterResets = pandoc.RawBlock('typst', build_counter_resets())

      -- Appendix chapters become H2 inside the appendices ambient
      el.level = el.level + 1
      return {counterStep, counterResets, el}
    end

    -- All other headings: shift down by 1 level
    -- H1 chapters become H2, H2 sections become H3, etc.
    el.level = el.level + 1
    return el
  end
}
