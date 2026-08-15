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
