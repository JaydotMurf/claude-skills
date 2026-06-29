/**
 * SHARED VISUAL CONTRACT — broll-pipeline
 *
 * This is the single source of truth every motion graphic must use. The BUILDER
 * subagent imports ONLY from this file: colors, type, timing, and the layout
 * primitives. It must not invent new palettes, fonts, or animation curves. If a
 * graphic needs something this file does not provide, the contract is extended
 * here once and reused — never forked per graphic. That is what keeps a whole
 * video's overlays looking like one designer made them.
 *
 * BUILD-TIME ASSUMPTION (no live interview was possible): the palette and type
 * below are a neutral, professional default. Replace COLORS and FONTS with the
 * user's real brand on first use; nothing else needs to change.
 */
import React from "react";
import {
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
  AbsoluteFill,
} from "remotion";

export const COLORS = {
  ink: "#0B0B0C", // primary text
  paper: "#FFFFFF", // surfaces
  muted: "#6B7280", // secondary text
  accent: "#2D6CDF", // brand accent — swap for the user's brand color
  accentSoft: "rgba(45,108,223,0.12)",
  line: "rgba(11,11,12,0.12)",
} as const;

export const FONTS = {
  display: "Inter, system-ui, -apple-system, sans-serif",
  mono: "'IBM Plex Mono', ui-monospace, monospace",
} as const;

// Animation primitives. Every graphic eases in/out with these so timing is uniform.
export const TIMING = {
  in: 14, // frames to animate in
  out: 12, // frames to animate out
} as const;

/** Spring-driven 0..1 entrance progress. */
export function useEnter(): number {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  return spring({ frame, fps, config: { damping: 200 }, durationInFrames: TIMING.in });
}

/** 1..0 exit progress over the last TIMING.out frames of the clip. */
export function useExit(): number {
  const frame = useCurrentFrame();
  const { durationInFrames } = useVideoConfig();
  return interpolate(
    frame,
    [durationInFrames - TIMING.out, durationInFrames - 1],
    [1, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
  );
}

/** Combined visibility (enter * exit), the opacity every primitive multiplies by. */
export function useVisibility(): number {
  return Math.min(useEnter(), useExit());
}

/** Slide-up + fade wrapper. The base motion for any element entering frame. */
export const Reveal: React.FC<{ children: React.ReactNode; delay?: number }> = ({
  children,
  delay = 0,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const enter = spring({
    frame: frame - delay,
    fps,
    config: { damping: 200 },
    durationInFrames: TIMING.in,
  });
  const exit = useExit();
  const opacity = Math.min(enter, exit);
  const y = interpolate(enter, [0, 1], [24, 0]);
  return (
    <div style={{ opacity, transform: `translateY(${y}px)` }}>{children}</div>
  );
};

/** Lower-third card: a title + optional subtitle pinned bottom-left. */
export const LowerThird: React.FC<{ title: string; subtitle?: string }> = ({
  title,
  subtitle,
}) => (
  <AbsoluteFill style={{ justifyContent: "flex-end", alignItems: "flex-start", padding: 80 }}>
    <Reveal>
      <div
        style={{
          background: COLORS.paper,
          borderLeft: `6px solid ${COLORS.accent}`,
          padding: "20px 28px",
          borderRadius: 10,
          boxShadow: "0 18px 50px rgba(0,0,0,0.18)",
          fontFamily: FONTS.display,
        }}
      >
        <div style={{ color: COLORS.ink, fontSize: 44, fontWeight: 700, lineHeight: 1.05 }}>
          {title}
        </div>
        {subtitle ? (
          <div style={{ color: COLORS.muted, fontSize: 26, marginTop: 6 }}>{subtitle}</div>
        ) : null}
      </div>
    </Reveal>
  </AbsoluteFill>
);

/** Big-stat card: one number with a label, centered. */
export const Stat: React.FC<{ value: string; label: string }> = ({ value, label }) => (
  <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
    <Reveal>
      <div
        style={{
          background: COLORS.accentSoft,
          border: `1px solid ${COLORS.line}`,
          borderRadius: 20,
          padding: "48px 64px",
          textAlign: "center",
          fontFamily: FONTS.display,
        }}
      >
        <div style={{ color: COLORS.accent, fontSize: 132, fontWeight: 800, lineHeight: 1 }}>
          {value}
        </div>
        <div style={{ color: COLORS.ink, fontSize: 34, marginTop: 12 }}>{label}</div>
      </div>
    </Reveal>
  </AbsoluteFill>
);

/** Bullet list that staggers each item in. */
export const BulletList: React.FC<{ heading?: string; items: string[] }> = ({
  heading,
  items,
}) => (
  <AbsoluteFill style={{ justifyContent: "center", alignItems: "flex-start", padding: 100 }}>
    <div style={{ fontFamily: FONTS.display }}>
      {heading ? (
        <Reveal>
          <div style={{ color: COLORS.ink, fontSize: 48, fontWeight: 700, marginBottom: 24 }}>
            {heading}
          </div>
        </Reveal>
      ) : null}
      {items.map((item, i) => (
        <Reveal key={i} delay={6 * (i + 1)}>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 16,
              color: COLORS.ink,
              fontSize: 36,
              margin: "10px 0",
            }}
          >
            <span style={{ width: 12, height: 12, borderRadius: 12, background: COLORS.accent }} />
            {item}
          </div>
        </Reveal>
      ))}
    </div>
  </AbsoluteFill>
);
