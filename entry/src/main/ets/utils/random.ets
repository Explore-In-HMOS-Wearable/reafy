import { cryptoFramework } from '@kit.CryptoArchitectureKit';

const rng = cryptoFramework.createRandom();

/**
 * Returns a cryptographically random integer in [0, max).
 */
export function cryptoRandInt(max: number): number {
  const blob = rng.generateRandomSync(4);
  const b = blob.data;
  const u32 = ((b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3]) >>> 0;
  return u32 % max;
}
