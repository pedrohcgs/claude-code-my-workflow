# Element Decision Trees

Quick decision frameworks for selecting the right HTML element.

## Is It a List?

```
Does knowing the count help the user?
├─ Yes → Are items sequential/ranked?
│        ├─ Yes → <ol>
│        └─ No → <ul>
├─ No → Are these term-description pairs?
│       ├─ Yes → <dl>
│       └─ No → Consider plain elements with appropriate structure
└─ Is it a toolbar of commands?
   └─ Yes → <menu>
```

## Is It a Table?

```
Does data have meaningful rows AND columns?
├─ No → Not a table
│       ├─ One dimension only → List or plain elements
│       ├─ Key-value pairs → <dl>
│       └─ Hierarchical → Nested lists or other structure
└─ Yes → Does each row have the same columns?
         ├─ No → Reconsider data structure
         └─ Yes → Use <table> with full semantics
```

## Button or Link?

```
Does this navigate to a new URL?
├─ Yes → <a href="...">
└─ No → Does an action occur?
        ├─ Yes → Would a URL provide useful fallback if JS fails?
        │        ├─ Yes → <a href="..."> with JS enhancement
        │        └─ No → <button>
        └─ No → Reconsider if interaction is needed
```

## Section or Div?

```
Does this content form a thematic grouping?
├─ No → <div>
└─ Yes → Can you provide a meaningful accessible name?
         ├─ Yes → <section aria-labelledby="...">
         └─ No → <div> (section without label ≈ div semantically)
```

## Article Candidate?

```
Would this content make sense standalone?
├─ Yes → Could it be syndicated or extracted?
│        ├─ Yes → <article>
│        └─ No → Use appropriate container (section, div, etc.)
└─ No → Use appropriate container (section, div, etc.)
```

## Which Landmark?

```
What is this section's purpose?
├─ Site/section header → <header>
├─ Site/section footer → <footer>
├─ Navigation → <nav> (must be labelled)
├─ Primary page content → <main>
├─ Search functionality → <search> (the form, not results)
├─ User input → <form> (must be labelled to be a landmark)
├─ Tangentially related → <aside>
├─ Self-contained content → <article>
└─ Thematic grouping with label → <section aria-labelledby="...">
```

## Form Field Grouping

```
Do these fields form a logical/thematic group?
├─ Yes → <fieldset> with <legend>
│        Examples: address fields, personal info, consent checkboxes
└─ No → Is visual grouping needed?
        ├─ Yes → <div> with appropriate styling
        └─ No → Fields can exist without wrapper
```

## Interactive Disclosure

```
Should content be expandable/collapsible?
├─ Yes → Is it a single content section?
│        ├─ Yes → <details>/<summary>
│        └─ No → Consider tab pattern or custom disclosure
└─ No → Is it a list of definitions?
        └─ Yes → <dl> (not details/summary)
```
