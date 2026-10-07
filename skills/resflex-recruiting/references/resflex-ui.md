# Resflex UI procedures

Resflex has no public API, so this skill drives the web UI through Claude in Chrome using the user's own signed-in session. If a page shows a login form, stop and ask the user to sign in. Never type credentials.

Load the Chrome tools in one batch before starting (`tabs_context_mcp`, `navigate`, `computer`, `find`, `get_page_text`, `browser_batch`), and work in a tab of the MCP tab group rather than the user's own tabs.

## Pages

| Page | URL |
|---|---|
| Interested list for an assignment | `https://resflex.com/candidates_list_int?a=<resflex_id>` |
| Candidate profile | `https://resflex.com/view_resume?c=<candidate_id>&a=<resflex_id>&l=int` |

- Get `candidate_id` from the name link's `href` with `find` ("<name> name link href").
- `get_page_text` on the list returns every row's name, company, title, location and Hiring Step in one call — use it for sweeps instead of screenshots.
- Profile text includes `Email:`, `Preferred Communication:`, the current Hiring Step with its latest note, and Candidate Notes (the user's own comments on fit — useful context; don't edit them).
- Profile actions include **Download as PDF** (Executive Summary, Profile, Prescreen, Notes) and **Export to Email**. Downloading a file needs the user's OK each time.
- Return to the list page when you're done with a profile.

## Changing a Hiring Step

The step is a dropdown button in the Hiring Step column ("New ▾", "Contacted ▾", …). Options: Reviewing, Contacted, Phone Interview, Video Interview, On-Site Interview, No Show, Offer Extended, Offer Accepted, Hired, Declined Offer, Withdrawn, Rejected, Future Consideration, Non responsive. Choosing one opens a modal titled with that step: one comment field, Cancel and OK.

**Gotcha:** clicking the dropdown by element `ref` has opened the *wrong* option's modal. Use screenshot coordinates, and verify the modal title before saving:

1. Scroll so the row is visible, then screenshot. Coordinates are only valid for the screenshot they came from.
2. Click the row's step button by coordinates.
3. Screenshot; click the target option by coordinates.
4. The page jumps to the top and the modal fades in. Wait ~1 s, then zoom on the modal (roughly x 348–1060, y 24–218 at a 1408×840 viewport) and **confirm the title is the intended step**. If it isn't: Cancel, reload, confirm no step changed, start over.
5. Click the comment field, type the note, zoom to check the text.
6. Click OK. Reload the list and confirm the row shows the new step.

Rate yourself on step 4, not on speed: a wrong step with a wrong note is visible to the recruiter and is hard to explain.
