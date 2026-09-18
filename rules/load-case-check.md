# Rule: load-case-check

Before delivering a part that carries or holds something (stands,
holders, hooks, brackets, wall mounts), work out which failure mode
governs. Calculate it; do not estimate it by eye. Check at least:

- **Breaking**: bending at the root of ribs, walls, or arms.
- **Tipping**: the whole part plus its load going over as one unit.
- **Sliding**: only where friction is what holds the part in place.

## How

- **Use the worst-case load combination, not the symmetric one.** A
  two-slot stand with only one slot filled has its center of gravity
  off to one side, and that is the case that tips first.
  (`laptop_tablet_staender_001` was delivered with a symmetric estimate
  of 12.9°. The real worst case, laptop alone in the outer slot, was
  8.0°, and the user only found it by asking.)
- **Mind layer direction.** When the bending stress runs along Z
  (across layers), layer adhesion is the limit, not bulk PLA strength.
  Use the conservative value in `context/materials.md`.
- **Put the calculation in the file.** Use `echo()` driven by the
  actual parameters: safety factor against breaking, tipping angle,
  and the push force that tips the part. If someone changes a dimension
  later, the numbers update with it. Make any assumed load (device
  mass, height) a parameter and label it as an assumption.
- **Name the governing failure mode** when reporting to the user, and
  say which failure modes are *not* critical. That tells the user
  which dimensions are safe to change. (Example: the stand's ribs had
  a safety factor of ~40, so tipping was the only real issue, and only
  foot width helped. Centered ballast added just 14 %.)
- **Before choosing a fix, compare the options in numbers** (for
  example foot flare vs. ballast vs. depth). What seems to help often
  doesn't.
