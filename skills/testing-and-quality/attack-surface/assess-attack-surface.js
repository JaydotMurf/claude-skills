// AssessAttackSurface — deep, efficient security assessment of one system from the
// attack-surface inventory. Fans out per-dimension finders, adversarially verifies each
// finding, synthesizes a severity-ranked report, and recommends a testing cadence.
//
// Canonical/versioned copy lives in the agent-skills library alongside the `attack-surface`
// skill. To RUN it, a copy must sit at ~/.claude/workflows/assess-attack-surface.js so the
// Workflow tool can resolve it by name: Workflow({ name: 'assess-attack-surface', args: {...} }).
// Keep the two in sync; the library copy is source of truth.
//
// args: {
//   system:  string   // system name, e.g. "vpatforge"
//   path?:   string   // repo path to read, e.g. "/Users/jerraill/dev/portfolio/vpatforge"
//   url?:    string   // live URL for external checks, e.g. "https://vpatforge.com"
//   inventory?: string // path to attacksurface.md (default ~/dev/attacksurface.md)
//   depth?:  'quick' | 'standard' | 'deep'  // default 'standard'
// }

export const meta = {
  name: 'assess-attack-surface',
  description: 'Deep security assessment of one inventoried system: recon, per-dimension finders, adversarial verification, cadence recommendation',
  whenToUse: 'Assess a specific attack surface from attacksurface.md thoroughly and efficiently, and recommend how often to re-test it.',
  phases: [
    { title: 'Recon', detail: 'map the system surface from inventory + code + live headers' },
    { title: 'Find', detail: 'parallel finders, one per security dimension' },
    { title: 'Verify', detail: 'adversarially refute each finding' },
    { title: 'Synthesize', detail: 'rank, recommend cadence, draft inventory update' },
  ],
}

const system = (args && args.system) || 'unknown-system'
const targetPath = (args && args.path) || ''
const liveUrl = (args && args.url) || ''
const inventory = (args && args.inventory) || '~/dev/attacksurface.md'
const depth = (args && args.depth) || 'standard'

// Dimensions scale with requested depth. Each is a distinct lens so finders don't overlap.
const CORE_DIMENSIONS = [
  { key: 'authn-authz', prompt: 'authentication and authorization: missing/broken auth, unauthenticated endpoints, admin surfaces, session/JWT/API-key handling, privilege boundaries, IDOR.' },
  { key: 'secrets-config', prompt: 'secrets and configuration: tracked secrets, key reuse/scope, env-var injection, debug mode in prod, exposed OpenAPI/admin, dashboard secret scoping, default credentials.' },
  { key: 'input-injection', prompt: 'input handling and injection: SQLi/NoSQLi, command/template injection, SSRF, path traversal, unsanitized free-text into emails/logs/HTML, deserialization, file upload.' },
  { key: 'transport-headers', prompt: 'transport and browser security: TLS/HTTPS, HSTS, CSP, X-Frame-Options, X-Content-Type-Options, CORS, cookie flags, CSRF protection on state-changing requests.' },
]
const EXTRA_DIMENSIONS = [
  { key: 'deps-supplychain', prompt: 'dependencies and supply chain: outdated/vulnerable packages, unpinned CI actions, publish-pipeline integrity (OIDC/tokens), typosquat/dependency-confusion exposure, untrusted CDN scripts.' },
  { key: 'exposure-network', prompt: 'network exposure: what is actually reachable and by whom (public/internal/localhost/VPN/token), port bindings (0.0.0.0 vs 127.0.0.1), rate limiting and its durability across restarts/instances, DoS/abuse vectors.' },
  { key: 'data-privacy', prompt: 'data and privacy: PII/financial/operational data at rest and in transit, retention/deletion/consent gaps, backup exposure, logging of sensitive data, regulatory exposure (GDPR/CCPA/PCI/CAN-SPAM).' },
]
const DIMENSIONS = depth === 'quick'
  ? CORE_DIMENSIONS
  : CORE_DIMENSIONS.concat(EXTRA_DIMENSIONS)

const SURFACE_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['tier', 'classification', 'exposure', 'stack', 'surfaces'],
  properties: {
    tier: { type: 'string', description: 'T1/T2/T3/T4 with one-line reason' },
    classification: { type: 'array', items: { type: 'string' } },
    exposure: { type: 'string', description: 'who can reach it: public/internal/localhost/VPN/token/OAuth' },
    stack: { type: 'string', description: 'languages, frameworks, hosting, DB, key vendors' },
    surfaces: { type: 'array', items: { type: 'string' }, description: 'concrete endpoints/ports/entry points' },
    authModel: { type: 'string' },
    sensitiveData: { type: 'string' },
    notes: { type: 'string' },
  },
}

const FINDINGS_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['findings'],
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['title', 'severity', 'evidence', 'impact'],
        properties: {
          title: { type: 'string' },
          severity: { type: 'string', enum: ['critical', 'high', 'medium', 'low', 'info'] },
          evidence: { type: 'string', description: 'file:line, config snippet, or live-response fact — no secret values' },
          impact: { type: 'string' },
          remediation: { type: 'string' },
        },
      },
    },
  },
}

const VERDICT_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['real', 'confidence', 'reason'],
  properties: {
    real: { type: 'boolean', description: 'true if the finding survives refutation' },
    confidence: { type: 'string', enum: ['high', 'medium', 'low'] },
    reason: { type: 'string' },
    correctedSeverity: { type: 'string', enum: ['critical', 'high', 'medium', 'low', 'info'] },
  },
}

// ---- Phase 1: Recon -----------------------------------------------------------
phase('Recon')
log(`Assessing "${system}" (depth: ${depth}, ${DIMENSIONS.length} dimensions)`)

const reconPrompt = `You are mapping the attack surface of a system I own, for an authorized security assessment.
System: ${system}
${targetPath ? `Code path: ${targetPath} — read deployment configs, READMEs, route/endpoint definitions, auth code, DB/config, and vendor integrations.` : ''}
${liveUrl ? `Live URL: ${liveUrl} — you MAY run read-only external checks (curl -sSI for headers, dig for DNS). Do NOT attempt exploitation, fuzzing, or auth bypass against the live host.` : ''}
Inventory file: ${inventory} — read this system's existing entry if present and reconcile with what you observe.

Produce a precise surface map. Never print secret values — record type and location only. Identify the criticality tier, classification, exposure audience, stack, and every concrete entry point (endpoints, ports, forms, webhooks, publish pipelines).`

const surface = await agent(reconPrompt, { label: `recon:${system}`, phase: 'Recon', schema: SURFACE_SCHEMA })

if (!surface) {
  log('Recon failed — aborting. Provide a valid path/url in args.')
  return { system, error: 'recon-failed' }
}
log(`Surface: ${surface.tier} · ${surface.exposure} · ${(surface.classification || []).join(', ')}`)

// ---- Phases 2+3: Find then adversarially Verify, pipelined per dimension -------
const surfaceContext = JSON.stringify(surface)

const perDimension = await pipeline(
  DIMENSIONS,
  // Stage 1 — find, scoped to one dimension
  (dim) => agent(
    `Authorized security assessment of "${system}". Surface map: ${surfaceContext}
${targetPath ? `Code path: ${targetPath}` : ''}${liveUrl ? ` · Live URL: ${liveUrl} (read-only checks only, no exploitation)` : ''}

Hunt ONLY within this dimension — ${dim.prompt}
Report concrete findings with evidence (file:line / config / live-response fact). Judge severity by real exploitability given the actual exposure (a default credential on a localhost-only bound port is not critical; the same on a public port is). Never print secret values. If the dimension is clean for this system, return an empty findings array — do not invent issues.`,
    { label: `find:${dim.key}`, phase: 'Find', schema: FINDINGS_SCHEMA },
  ),
  // Stage 2 — adversarially verify each finding from this dimension (no barrier across dimensions)
  (result, dim) => {
    const findings = (result && result.findings) || []
    if (!findings.length) return []
    return parallel(findings.map((f) => () =>
      agent(
        `Adversarially REFUTE this security finding for "${system}". Assume it is wrong until the evidence forces otherwise. Consider: is the code path reachable given exposure "${surface.exposure}"? Is there a compensating control? Is the severity inflated for a ${surface.tier} system?
Finding: ${JSON.stringify(f)}
Surface: ${surfaceContext}
Return real=false if it does not hold up, and correct the severity if it is mis-rated.`,
        { label: `verify:${dim.key}:${f.title.slice(0, 30)}`, phase: 'Verify', schema: VERDICT_SCHEMA },
      ).then((v) => ({ ...f, dimension: dim.key, verdict: v })),
    ))
  },
)

const confirmed = perDimension
  .flat()
  .filter(Boolean)
  .filter((f) => f.verdict && f.verdict.real)
  .map((f) => ({ ...f, severity: (f.verdict.correctedSeverity || f.severity) }))

const sevRank = { critical: 0, high: 1, medium: 2, low: 3, info: 4 }
confirmed.sort((a, b) => (sevRank[a.severity] ?? 9) - (sevRank[b.severity] ?? 9))
log(`Confirmed ${confirmed.length} finding(s) across ${DIMENSIONS.length} dimensions`)

// ---- Phase 4: Synthesize + cadence recommendation -----------------------------
phase('Synthesize')

const synthesis = await agent(
  `You are writing the assessment report for "${system}", an authorized security review of a system I own.
Surface map: ${surfaceContext}
Confirmed findings (severity-ordered, already adversarially verified): ${JSON.stringify(confirmed)}

Write a concise report:
1. One-paragraph posture summary (overall risk given exposure + data sensitivity).
2. Findings, most severe first — title, severity, impact, concrete remediation. Group trivial items.
3. A recommended TESTING CADENCE with explicit rationale, derived from criticality (exposure x data sensitivity x blast radius) WEIGHED AGAINST cost (effort to run this assessment). Give the trigger type: calendar (monthly/quarterly/semi-annual), per-deploy, per-release, or event ("on exposure change"). A localhost/not-reachable system should be event- or release-triggered, not put on an expensive calendar.
4. A ready-to-paste "Known-issue watchlist" block for this system's section in ${inventory}, most-actionable first.
Never print secret values. Be precise and honest — if the system is in good shape, say so plainly.`,
  { label: `synthesize:${system}`, phase: 'Synthesize' },
)

return {
  system,
  tier: surface.tier,
  exposure: surface.exposure,
  findingsCount: confirmed.length,
  bySeverity: confirmed.reduce((acc, f) => ({ ...acc, [f.severity]: (acc[f.severity] || 0) + 1 }), {}),
  confirmed,
  report: synthesis,
  note: `Fold the watchlist + findings into ${inventory} via the attack-surface skill, and update Last-full-sweep for ${system}.`,
}
