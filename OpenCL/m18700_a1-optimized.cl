/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

//#define NEW_SIMD_CODE

#include "inc_vendor.cl"
#include "inc_hash_constants.h"
#include "inc_hash_functions.cl"
#include "inc_types.cl"
#include "inc_common.cl"
#include "inc_scalar.cl"
#include "inc_simd.cl"
#include "inc_hash_md5.cl"

DECLSPEC u32 hashCode_g (const u32 init, __global u32 * restrict w, const u32 pw_len)
{
  u32 hash = init;

  for (u32 i = 0; i < pw_len; i += 4)
  {
    u32 tmp = w[i / 4];

    const u32 left = pw_len - i;

    const u32 c = (left > 4) ? 4 : left;

    switch (c)
    {
      case 4: hash *= 31; hash += tmp & 0xff; tmp >>= 8;
      case 3: hash *= 31; hash += tmp & 0xff; tmp >>= 8;
      case 2: hash *= 31; hash += tmp & 0xff; tmp >>= 8;
      case 1: hash *= 31; hash += tmp & 0xff;
    }
  }

  return hash;
}

__kernel void m18700_m04 (KERN_ATTR_BASIC ())
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);

  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    u32 hash = 0;

    if (combs_mode == COMBINATOR_MODE_BASE_LEFT)
    {
      hash = hashCode_g (hash, pws[gid].i,          pws[gid].pw_len);
      hash = hashCode_g (hash, combs_buf[il_pos].i, combs_buf[il_pos].pw_len);
    }
    else
    {
      hash = hashCode_g (hash, combs_buf[il_pos].i, combs_buf[il_pos].pw_len);
      hash = hashCode_g (hash, pws[gid].i,          pws[gid].pw_len);
    }

    const u32x r0 = hash;
    const u32x r1 = 0;
    const u32x r2 = 0;
    const u32x r3 = 0;

    COMPARE_M_SIMD (r0, r1, r2, r3);
  }
}

__kernel void m18700_m08 (KERN_ATTR_BASIC ())
{
}

__kernel void m18700_m16 (KERN_ATTR_BASIC ())
{
}

__kernel void m18700_s04 (KERN_ATTR_BASIC ())
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);

  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * digest
   */

  const u32 search[4] =
  {
    digests_buf[digests_offset].digest_buf[DGST_R0],
    0,
    0,
    0
  };

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    u32 hash = 0;

    if (combs_mode == COMBINATOR_MODE_BASE_LEFT)
    {
      hash = hashCode_g (hash, pws[gid].i,          pws[gid].pw_len);
      hash = hashCode_g (hash, combs_buf[il_pos].i, combs_buf[il_pos].pw_len);
    }
    else
    {
      hash = hashCode_g (hash, combs_buf[il_pos].i, combs_buf[il_pos].pw_len);
      hash = hashCode_g (hash, pws[gid].i,          pws[gid].pw_len);
    }

    const u32x r0 = hash;
    const u32x r1 = 0;
    const u32x r2 = 0;
    const u32x r3 = 0;

    COMPARE_S_SIMD (r0, r1, r2, r3);
  }
}

__kernel void m18700_s08 (KERN_ATTR_BASIC ())
{
}

__kernel void m18700_s16 (KERN_ATTR_BASIC ())
{
}
