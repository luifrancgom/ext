# Request for adding quarto-cli feature for html

## Using

Inspecting the minimal reproducible example as an extension 

```bash
quarto use template luifrancgom/ext
```

## Minimal reproducible example options

- `label.roles` (default: `roles`): heading text shown above the roles column in the title block. Override in document metadata, e.g.:

  ```yaml
  format:
    ext-html:
      label:
        roles: Contributions
  ```

## Code and demo

Here is the source code for a minimal sample document: [template.qmd](template.qmd).

Here is the minimal sample document rendered in html format: [Demo](https://luifrancgom.github.io/ext/)

## Extension source code structure

```
_extensions/ext/
├── _extension.yml
├── filters/
│   └── by-role.lua
├── partials/
│   ├── title-block.html
│   ├── title-metadata.html
│   ├── _title-meta-grid.html
│   ├── _title-meta-author.html
│   └── _title-meta-role.html
└── styles/
    └── custom.scss
```

- `filters/by-role.lua`: mimics how quarto-cli builds `by-author` and `by-affiliation`, producing a `by-role` metadata structure that the partials (especially `_title-meta-grid.html`) can use. This is also what makes the `/first` pipe usable in Pandoc templates (e.g. `$if(by-role/first)$`), the same way it's usable with `by-affiliation/first`.
- `partials/title-block.html`: the title block for the `html` format only, excluding the banner/manuscript variants used elsewhere in quarto.
- `partials/title-metadata.html`: the other title metadata options used in quarto's `html` format.
- `partials/_title-meta-grid.html`: adds the roles column and coordinates its layout with the author and affiliation columns.
- `partials/_title-meta-author.html`: adds the `position` option.
- `partials/_title-meta-role.html`: includes role metadata following the CRediT taxonomy.
- `styles/custom.scss`: grid/layout CSS rules for the title-meta block (roles, affiliations, authors columns).

