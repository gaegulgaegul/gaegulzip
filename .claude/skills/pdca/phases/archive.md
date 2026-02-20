# archive (Archive Phase)

1. Verify Report completion (phase = "completed" or matchRate >= 90%)
2. Create `docs/archive/YYYY-MM/{feature}/` folder
3. Move all documents (check all platform-specific paths)
4. Update `.pdca-status.json`: phase = "archived"

**Documents to Archive** (check all locations per platform):
- Plan: `docs/{product}/{feature}/user-story.md`
- Server: `docs/{product}/{feature}/` (server-brief, server-work-plan, server-cto-review)
- Mobile: `docs/{product}/{feature}/` (mobile-design-spec, mobile-brief, mobile-work-plan, mobile-cto-review)
- Web: `docs/{product}/{feature}/` (web-design-spec, web-brief, web-work-plan, web-cto-review)
- Analysis: `docs/{product}/{feature}/analysis.md`
- Report: `docs/{product}/{feature}/report.md`
