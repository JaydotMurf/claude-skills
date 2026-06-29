// Remotion entry point. Registers the root so `npx remotion render` can find the
// "Graphic" and "Reference" compositions.
import { registerRoot } from "remotion";
import { RemotionRoot } from "./Root";

registerRoot(RemotionRoot);
