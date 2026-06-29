<prompt>
<task>
Create a new skill for my AI coding agent called "goal-prompt-generator", stored
wherever my harness loads skills from.

The skill's job: turn an implementation plan or task description into a bounded goal
prompt another agent session can pursue autonomously and be checked against.

The skill must include: (1) trigger conditions — when I ask you to package work for
another session, write a goal prompt, or prepare a task for autonomous execution;
(2) a required structure for every goal prompt: the objective in one paragraph; an
explicit DEFINITION OF DONE as a checklist of verifiable statements; repo constraints
(files/areas that may be modified, files/areas that must NOT be touched); verification
gates — the exact commands to run and expected results before claiming completion; and
stop conditions — situations where the agent must halt and ask instead of improvising;
(3) a self-containment rule: the receiving session has none of our conversation
context, so the prompt must include exact paths and all needed background; (4) a
quality check before delivering: "could a competent agent with zero context execute
this and could I verify the result without re-deriving the plan?"

After writing it, test it by packaging the next real task I describe into a goal
prompt.
</task>
</prompt>
