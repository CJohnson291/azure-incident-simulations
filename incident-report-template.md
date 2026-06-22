# Incident Report: [Short Title]

**Scenario #:** [e.g. 01]
**Date:** [DD/MM/YYYY]
**Environment:** [e.g. App 1 - baseline VM]
**Severity (self-assessed):** [Low / Medium / High]
**Time to resolution:** [e.g. 45 minutes]

---

## 1. Ticket

> [Paste the exact ticket text you were given, verbatim]

## 2. Initial Triage

What you checked first, and why. What assumptions you made going in.

## 3. Investigation

Step-by-step account of your investigation — commands run, tools used,
what you observed at each step. Include relevant CLI output or screenshots.

```
[command / output]
```

## 4. Root Cause

What was actually wrong, and why it caused the reported symptoms.

## 5. Resolution

Steps taken to fix it. Include commands/config changes.

```
[command / config]
```

## 6. Verification

How you confirmed the fix worked (e.g. curl output, screenshot of the
app responding, metrics returning to normal).

## 7. What Was Actually Changed (Reveal)

[Filled in after resolution] — the actual fault-injection script/change,
compared against your root cause analysis in Section 4. Note any gaps
between what you diagnosed and what was actually wrong.

## 8. Learning Notes

- What went well
- What took longer than expected, and why
- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed
- What you'd check first if this happened again
- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
