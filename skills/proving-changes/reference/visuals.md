# Compact visuals for evidence and PR bodies

Adapted from HumanLayer's `show-me` skill. Prose makes the reader rebuild structure in their head. A fenced text block shows the structure directly. Use these in PR descriptions, `REPORT.md`, and chat replies. Plain text in a fenced block renders everywhere. Use Mermaid only when the user asks or the host renders it and the diagram type fits.

Pick the diagram from the hard part of the change, not from habit.

| The hard part is... | Diagram |
| --- | --- |
| When things happen (races, reloads, cancels, timeouts) | Timeline |
| Which state we are in at each moment | State ladder |
| Which branch the code takes | Decision tree |
| What runs, in what order | Call stack, with diff marks |
| What renders, and what owns state | Component tree, with diff marks |
| Where files moved | File layout, with diff marks |
| What the data looks like at a hop | Payload snapshot |
| What an algorithm does | Pseudocode |
| Behavior before vs after | Two-column table |

## Timeline

For any bug that depends on ordering. Events as marks on a time axis. Dashed line for a cut (reload, commit, timeout). A ghosted event for one that never arrives. Two lanes for two actors. Two timelines (normal vs failing) beat one busy one.

```
normal turn
  user sends ──── stream starts ──── tokens ──── stream_complete ──── persisted
                                                       │
                                     reload here reads afterTurn=3, sees turn-4 events: shows them

compaction mid-turn
  user sends ──── stream starts ──── compaction writes user msg ──── tokens ──── stream_complete
                                              │
                          reload here reads afterTurn=4, turn-4 events are "old": fenced out, blank
```

## State ladder

The same structure snapshotted at named cut points, with a one-line predicate that classifies each. Use it when the story is "what do we hold at this moment" rather than "what changed".

```
S0  history: []                          in-flight? no   (nothing to replay)
S1  history: [t4:token, t4:token]        in-flight? yes  (newest turn == afterTurn, no stream_complete)
S2  history: [t4:token, t4:complete]     in-flight? no   (newest is stream_complete)
S3  history: [t3:complete, t4:token]     in-flight? yes  (newest turn == afterTurn)
```

## Decision tree

For classification logic. One question per line, indented answers.

```
newest history event
├── none                          → fresh session, replay nothing
├── turn < afterTurn              → stale, replay nothing
├── turn == afterTurn
│   ├── type == stream_complete   → done, replay nothing
│   └── else                      → in flight, replay turn events, keep live subscription
└── turn > afterTurn              → newer than persisted, replay all
```

## Call stack with diff marks

For control-flow changes. Indentation is the call depth. `+` and `-` mark what the PR adds or removes.

```
  handleReload
    readHistory(afterTurn)
+     classifyNewestPayload
+       inFlightTurn = turn if newest is not stream_complete
    replay(events)
-     filter turn > afterTurn
+     filter turn > afterTurn || turn == inFlightTurn
    subscribeLive
```

## Component tree with diff marks

For UI changes. Keep the hooks and boundaries that matter, drop the rest.

```
  <ChatSession>
    useChat()
+     replacesPersistedTurn
    <MessageList>
      <Message>
+       <StreamingIndicator />
    <Composer>
```

## File layout with diff marks

For moves and splits. One line of responsibility per entry.

```
  components/files/
- ├── UploadedDocumentViewer.tsx      # 1300 lines, every viewer in one file
+ ├── viewers/
+ │   ├── ImageViewer.tsx             # verbatim from monolith, 29/29 lines
+ │   ├── SourceViewer.tsx            # verbatim, 92/92 lines
+ │   └── DocAuthViewer.tsx           # 67 lines changed: save path, size gate
+ └── DocumentSaveButton.tsx          # rewritten, 8/45 lines verbatim
```

## Payload snapshot

Real captured data, not hand-written. Mark the field the story follows.

```
POST /api/files/<id>/docx-edit
Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document
request body bytes: 59145    wire Content-Length: 59145
first four bytes: 50 4b 03 04   (PK, a ZIP)
response 200 {"versionId": "...", "bucketPath": "..."}
```

## Pseudocode with diff marks

For algorithmic changes where the thing to show is logic, not code.

```
on(reload)
  events = history(afterTurn)
- keep events where turn > afterTurn
+ inFlight = newest.turn if newest.type != stream_complete
+ keep events where turn > afterTurn or turn == inFlight
  render(keep)
```

## Before/after table

For the live reproduction. One row per named moment. One column per variant. Cells hold the observation, not an adjective.

```
| moment                  | base (dev)                          | branch                                   |
| ----------------------- | ----------------------------------- | ---------------------------------------- |
| 1 streaming, pre-reload | 412 chars, stop button visible      | 408 chars, stop button visible           |
| 2 after reload          | 0 chars, send enabled, no stream    | 1,190 chars, stop button, still streaming|
| 3 reload + 10s          | 0 chars                             | 3,020 chars                              |
| 4 second send           | accepted, turn lost                 | blocked while streaming                  |
| 5 final                 | assistant turn missing              | full assistant turn persisted            |
```

## Rules

- One idea per visual. Two small diagrams beat one that needs a legend.
- Real names from the code and real values from the run. Never invent a field or a number.
- Square corners and plain characters. No color, no emoji.
- Put the visual where the reader needs it: the ELI5 gets the timeline or decision tree, "What changed" gets the call-stack or component diff, "Proof" gets the table and screenshots.
