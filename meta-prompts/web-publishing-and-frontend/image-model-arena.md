<prompt>
<task>
Create a new skill for my AI coding agent called "image-model-arena", stored wherever
my harness loads skills from.

The skill's job: build and publish image-model comparison pages — one review page per
model plus a shared side-by-side viewer — generated from a single config.

This skill COMPOSES two skills I already have: image generation goes through my
image-gateway skill, and publishing goes through my site-publisher skill. It must
never reimplement either.

Before writing it, interview me for: my standard test prompt set (help me design 6–10
prompts covering photorealism, text rendering, diagrams, people, and style range), and
where comparison configs and generated images should live.

The skill must include: (1) trigger conditions — when I want to test a new image
model, compare models, or add a model to an existing comparison; (2) a single config
format defining models, prompts, and page metadata; (3) the pipeline: generate via
image-gateway, optimize images for web, build per-model pages and the shared
comparison viewer, publish via site-publisher; (4) a model registry tracking per-image
cost and content-policy quirks observed; (5) regeneration support — adding one model
must not require redoing the others.

After writing it, test it with two models on a 3-prompt subset before running anything
at full scale.
</task>
</prompt>
