<prompt>
  <task>
    Create a skill (plus two subagents) for my AI coding agent called "broll-pipeline",
stored wherever my harness loads skills from.

The job: an end-to-end pipeline that takes a finished talking-head video plus its
timestamped transcript and produces animated motion-graphic overlays composited onto
the video at the right moments.

Architecture — three pieces:

1. A SCOUT subagent: reads the chaptered transcript and selects which moments deserve
   a graphic, enforcing density and spacing rules (a target of graphics-per-minute and
   a minimum gap between them), and writes a manifest: timestamp in/out, concept, and
   the data or text each graphic should show.
2. A BUILDER subagent: takes 2–3 manifest entries at a time and generates Remotion
   (React video) components for them against a SHARED VISUAL CONTRACT — one TypeScript
   file defining the palette, typography, animation primitives, and layout components
   every graphic must use. The contract is what keeps all graphics consistent.
3. The ORCHESTRATOR skill: runs scout → builder batches → render each clip → composite
   clips onto the source video at manifest timestamps with ffmpeg → final output. It
   keeps a pipeline state file so a long run can resume from any stage after
   interruption.

Before building, interview me for: my brand palette and typography for the visual
contract, my target graphic density, and output specs (resolution, platforms).

Build it in stages and verify each before moving on: contract first, then one
hand-written reference graphic we approve together, then the scout, then the builder
(validated against the contract), then rendering and compositing. Test the full
pipeline on a short video (2–3 minutes) before any real footage.
</task>
</prompt>
