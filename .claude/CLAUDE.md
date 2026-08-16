# Collaboration Guidelines

## Approach: Theory First, Implementation Second
- Iterate on approach and design through discussion
- Plan which files/components will be affected upfront
- Clarify all solution constraints before writing code
- Implement in one focused effort after approach is settled

## Always Ask About
- **Multiple solution approaches**: "make a backup system" has dozens of implementations - ask about constraints, storage, scope, retention
- **Ambiguous requirements**: even if the user doesn't realize they're ambiguous - probe for the complete mental model
- **Missing requirements**: when implementation needs decisions not specified
- **Conflicting requirements**: when specifications contradict each other
- **Multi-file changes not discussed upfront**: if implementation scope grows beyond initial discussion
- **Purpose-unclear technical choices**: hash vs random vs uuid - ask about the underlying need
- **Enhancement/convenience dependencies**: tqdm, rich output, specialized libraries - even if safe

## Never Ask About
- **Anything covered in this style guide**: naming, formatting, structure patterns, error handling approach
- **Functional dependency necessities**: pandas for CSV, requests for HTTP, pathlib for files, numpy, pytorch
- **Single-file focused changes** when scope matches expectations
- **Technical implementation details** when requirements and approach are clear

# Writing Files

- **Never hard-wrap prose.** Let a paragraph run as one line; break only where a break is real — between paragraphs, list items, headings. Applies to every file type: markdown, docstrings, comments, commit messages, PGN comment text.
- **Why:** hard wraps corrupt diffs (a one-word edit reflows the whole paragraph), they fight editors that soft-wrap anyway, and they make text harder to edit programmatically.

# Python Coding Style Guidelines

## Design & Architecture
- **Simplicity over optimization**: Prefer readable code over complex optimizations
- **Learn from existing code**: Study similar functions as templates before creating new ones
- **Template method pattern** to eliminate duplication
- **Symmetrical APIs** across related classes
- **Fail-fast validation** (authenticate in `__init__`)
- **Native sync/async** implementations, no thread pool faking
- **Single responsibility** for abstract methods
- **Explicit over implicit**: Make design choices clear and intentional

## Code Implementation

### Functions
- **Keep functions short and focused** (aim for ~20-30 lines)
- Use the same structure as similar existing functions
- Avoid nested helper functions unless absolutely necessary
- **Make key parameters configurable** with sensible defaults

### Error Handling
- **Simple, direct error handling**: no complex retry logic unless explicitly stated
- Let functions fail naturally if assumptions aren't met
- Don't add sophisticated error recovery unless explicitly needed

### Classes
- **Focused classes** with essential methods only
- **Remove dead code** proactively

## Anti-Patterns to Avoid
- Complex loops with safety limits and exception handling
- Long `while True` loops with complex break conditions
- Field discovery and schema introspection when not needed
- Functions that impose behavior on their callers
- Hardcoded assumptions about data structure
- Rigid design choices that prevent flexibility
- Making assumptions about solution approach when multiple valid options exist

## Python Language

### Type System
- Use Python 3.10+ native type hints: `list[str]`, `dict[str, Any]`
- Create type aliases for reusable complex types: `Messages = list[dict[str, str]]`

### Imports
- **Follow Python import order**: standard library, external libraries, local modules
- **Import at module level**: avoid nested imports within functions
- Import abstract decorators: `from abc import abstractmethod`

## Style & Conventions

### Naming
- **Concise but meaningful**: `drop_messages()` not `delete_last_messages()`
- **Remove redundancy**: `_should_retry()` not `_is_retryable_error()`
- **Short parameters**: `n` for counts, standard abbreviations only
- **No arbitrary abbreviations**: Keep `messages`, not `msgs`
- **Consistent terminology**: Use the same term across modules

### Documentation & Comments
- **Concise and specific docstrings**: State exactly what the method does
- **One-line docstrings** for simple methods when possible
- **Multiline docstrings start with newline**: `"""\n    Functional description.`
- **No verbose Args/Returns** unless method or data types are complex
- **No module-level docstrings**: Let class docstrings provide context
- **Functional comments** that describe *what* the code does, not *how*
- **In-line comments are lowercase**: `# this is a concise comment`
- **Natural text flow**: No arbitrary line breaks
- **Print using f-strings**: `print(f"Error: {e}")` for readability
- **Never use emojis** in code, comments, or print statements

### File Organization
- **Semantic file names**: singular for subsystems (`client.py`, `session.py`), plural for collections (`commands.py`, `models.py`)
- **Newlines at end of files** following Unix convention

## Examples

### Good: Simple and Direct
```python
def bulk_create_doc_content(azs_client, docs, n=10, batch_size=50):
    doc_contents = []
    for i in range(0, len(doc_ids), batch_size):
        # simple batch processing
        content = process_batch(...)
        doc_contents.append(content)
    return join_results(doc_contents)
```

### Bad: Over-Engineered
```python
def bulk_create_doc_content(azs_client, docs, n=10):
    # discover fields dynamically
    sample = discover_schema(azs_client)
    # complex pagination with limits
    while True:
        try: 
            # nested error handling
        except ComplexException:
            # retry logic
```
