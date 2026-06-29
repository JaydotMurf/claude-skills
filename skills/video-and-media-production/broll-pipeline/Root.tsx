/**
 * Remotion root for broll-pipeline.
 *
 * One parametric composition, "Graphic", renders every manifest entry. The
 * orchestrator renders it once per entry, passing that entry as --props and
 * letting calculateMetadata set the clip duration from (out - in). A second
 * composition, "Reference", is the hand-written graphic the human approves
 * before the BUILDER is allowed to generate anything.
 *
 * The BUILDER extends GRAPHIC_TYPES with new layouts, but every layout it adds
 * must be built only from the primitives in ./visual-contract.tsx.
 */
import React from "react";
import { Composition, AbsoluteFill, CalculateMetadataFunction } from "remotion";
import { COLORS, Stat, LowerThird, BulletList } from "./visual-contract";

export type GraphicProps = {
  id: string;
  type: "stat" | "lowerThird" | "bulletList";
  in: number; // seconds into the source video
  out: number; // seconds
  concept?: string;
  data?: {
    value?: string;
    label?: string;
    title?: string;
    subtitle?: string;
    heading?: string;
    items?: string[];
  };
};

/** type -> contract component. The only place a graphic type is resolved. */
function GraphicRouter({ type, data = {} }: GraphicProps) {
  switch (type) {
    case "stat":
      return <Stat value={data.value ?? ""} label={data.label ?? ""} />;
    case "lowerThird":
      return <LowerThird title={data.title ?? ""} subtitle={data.subtitle} />;
    case "bulletList":
      return <BulletList heading={data.heading} items={data.items ?? []} />;
    default:
      return null;
  }
}

/**
 * Graphics render on transparency so ffmpeg can overlay them on the source.
 * Never paint a full-frame background here. calculateMetadata sets per-clip
 * duration and forces the transparent ProRes 4444 codec.
 */
const Graphic: React.FC<GraphicProps> = (props) => (
  <AbsoluteFill style={{ backgroundColor: "transparent" }}>
    <GraphicRouter {...props} />
  </AbsoluteFill>
);

const calculateMetadata: CalculateMetadataFunction<GraphicProps> = async ({
  props,
}) => {
  const fps = 30;
  const seconds = Math.max(0.5, (props.out ?? 0) - (props.in ?? 0));
  return {
    durationInFrames: Math.round(seconds * fps),
    defaultCodec: "prores",
    defaultVideoImageFormat: "png",
    defaultPixelFormat: "yuva444p10le",
    defaultProResProfile: "4444",
  };
};

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="Graphic"
        component={Graphic}
        durationInFrames={150}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{
          id: "preview",
          type: "stat",
          in: 0,
          out: 5,
          data: { value: "82%", label: "of pilots shipped on time" },
        }}
        calculateMetadata={calculateMetadata}
      />
      <Composition
        id="Reference"
        component={Graphic}
        durationInFrames={150}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{
          id: "reference",
          type: "lowerThird",
          in: 0,
          out: 5,
          data: { title: "Jordan Ellis", subtitle: "Program Manager, DIU" },
        }}
      />
    </>
  );
};
