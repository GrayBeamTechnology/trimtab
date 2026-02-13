# Call Me Trimtab

## I.

Buckminster Fuller's gravestone bears three words: **CALL ME TRIMTAB.**

A trim tab is a small metal surface — six inches wide — hinged to the trailing edge of a ship's rudder. When it moves, it creates a low-pressure zone that pulls the rudder around. The rudder turns the ship. You never push the ship directly.

Fuller saw this as a metaphor for how individuals change systems. Not by force. By placement. Find the trailing edge, apply a small precise force, and the geometry of the system does the rest.

## II.

Joe Armstrong built Erlang because he understood something similar about failure.

Telephone switches need 99.999% uptime. The obvious approach: prevent every possible failure. Armor the hull. The more you prevent, the more complex the prevention becomes, and the more catastrophic the failures you didn't predict.

Armstrong's insight was Fuller's insight wearing different clothes: **don't prevent failure — make the geometry resilient to it.**

An Erlang supervision tree is a trim tab for reliability. Three lines of configuration — a restart strategy — govern the recovery behavior of a hundred concurrent processes. When a process dies, its supervisor restarts it. The individual process doesn't need to be bulletproof. The *structure* handles the failure.

This is tensegrity applied to software. Isolated components (compression members) floating in a continuous network of message passing (tension). One member fails, the structure holds.

## III.

Donald Knuth spent fifty years writing *The Art of Computer Programming* because he understood the prerequisite that Fuller and Armstrong's work implies but doesn't always state:

**You can only place a trim tab if you know where the forces converge.**

Fuller's geometry works because he studied nature's structural principles for decades before designing a single dome. Armstrong's "let it crash" works because he analyzed telephone switching patterns deeply enough to know that restart-from-clean-state solves 90% of failures.

Knuth's contribution is the discipline underneath. His obsession with algorithmic analysis isn't academic vanity — it's the practice of understanding a system deeply enough that you can identify the four lines that matter. His famous dictum — "premature optimization is the root of all evil" — is a warning against pushing the hull. Don't apply force until you know where the trailing edge is.

## IV.

These three principles converge in how we work with AI.

As coding agents grow more capable — Claude Code, Codex, OpenCode, and whatever comes next — the instinct is to push the hull. More prompts. More oversight. More dashboards monitoring the AI's work. More process wrapping the AI's output.

The trim tab practitioner asks a different question: **what's the smallest surface that steers the most behavior?**

A `CLAUDE.md` file is a trim tab. A few hundred lines of text that govern every interaction across an entire project. Written well, it makes thousands of micro-corrections unnecessary. Written poorly — or not written at all — and you're back to pushing the hull with every prompt.

Memory files are trim tabs that compound. Each session deposits a small insight. Over weeks, those insights accumulate into a navigational surface that steers future sessions without any active effort.

Observation systems — like a background process that watches conversation length and triggers reflection — are Armstrong's supervisors applied to AI collaboration. They don't prevent bad outputs. They create a geometry where recovery is automatic.

Task structures are Knuth's discipline. Knowing which work matters before the agent starts. The analysis that earns you the right to say "do this, not that" with confidence.

## V.

The trim tab principle scales down to a single shell command.

Instead of opening eight projects to check what's running, six lines of `ss` and `git log` give you the shape of your entire workday. Instead of a sprawling monitoring dashboard, a 30-second `watch` loop in tmux tells you everything that changed.

The question is always the same: **what's the smallest surface?**

Not the most comprehensive. Not the most elegant. Not the most featureful. The smallest surface that, placed on the trailing edge, steers the ship.

Fuller. Armstrong. Knuth. Three people who understood that the world is moved not by the biggest force, but by the best-placed one.

---

*trimtab.dev — find the small surface that steers the ship.*
