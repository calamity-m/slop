# Sibling Pattern Extraction

When finding sibling code, search by directory structure, base classes, shared interfaces, or naming convention. If the diff touches a REST controller, find the other controllers. If it adds a config class, find the other config classes. If it creates a service, find the sibling services.

Read at least 2-3 siblings in full before reporting.

## What to Extract

- **Structural patterns**: composition vs inheritance, how dependencies are injected, how modules are organized
- **Method style**: behavior on the object vs utility/static helpers vs functional chains (streams, `.map().filter()`, iterators)
- **Error handling style**: exceptions vs result types vs error codes, where and how errors are wrapped
- **Naming**: not just identifiers but the conceptual vocabulary (e.g., does this codebase say "handler" or "controller", "service" or "manager")
- **Test patterns**: how siblings are tested, what is mocked, what assertions look like
- **Configuration and wiring**: how similar components are registered, configured, or composed

## Why This Matters

The sibling search is the most important step of the review. The patterns found here become the standard that the consistency lens measures against. If siblings are not read, the consistency lens has nothing to compare to and becomes guesswork.
