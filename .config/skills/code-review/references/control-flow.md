# Control-Flow Style Taxonomy

Trace 2-3 representative call chains from public entry points through to their terminal operations. Identify which pattern the codebase uses.

## Styles

### Visible Control (preferred default)

Public methods contain the control flow and sequencing. Private/helper methods encapsulate contained logic but do not make control decisions or chain deeper. The reader can understand the full flow from the public method alone.

```
public process(request):
    validated = validate(request)       // helper: validates, returns or throws
    result = transform(validated)       // helper: pure transformation
    store(result)                       // helper: writes to storage
    notify(result)                      // helper: sends notification
    return result
```

### Cascading Delegation

Public methods call private methods, which call other private methods, forming a deep call chain. Control is distributed across layers.

```
public process(request):
    return handleRequest(request)       // control disappears into the chain
        -> validateAndTransform(request)
            -> applyBusinessRules(data)
                -> persistAndNotify(result)
```

### Event-driven / Message-passing

Rather than direct function calls, components communicate through channels, events, or message buses. Control flow is implicit in the wiring, not the call graph.

```
public process(request):
    eventBus.publish(RequestReceived(request))
    // flow continues in listeners/subscribers
```

### Pipeline / Functional Composition

Data flows through a chain of transformations. Control is the shape of the chain.

```
public process(request):
    return pipeline(request)
        .map(validate)
        .map(transform)
        .flatMap(store)
        .map(notify)
```

## How to Report

State which style the codebase uses. If different areas use different styles, note that.

If no clear style is established, **default to visible control** — that is the preferred style when the repo has no opinion.
