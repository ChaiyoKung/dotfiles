---
created: 2026-10-16T10:45:15Z
updated: 2026-10-16T10:45:15Z
---

# Reliability

- **I design for the worst case when a failure would have a big impact.** An automated system that nobody watches is a clear example. It must be reliable to a level that fits the impact, so I think about what can go wrong before I build.
- **I never trust an external system.** I assume it can fail, be slow, or return wrong data. I plan a response first, such as a retry, a fallback, or an alert. How much I check again depends on the cost and the risk.
- **I put a cap on anything that can grow without limit.** Retries, history, parallel work, and waiting time all get a cap from the start. Then I can say the worst case for cost and time. When a cap is hit, it must be visible, and the system must have a planned way out.
