# Lessons learned

Document what broke, how you diagnosed it, and what you'd do differently.

---

## Template

### Issue: [Brief description]

**What happened:**
[Describe the unexpected behavior]

**Root cause:**
[What was actually wrong]

**How I diagnosed it:**
[Step-by-step: what logs you checked, what tools you used]

**Resolution:**
[What fixed it]

**What I'd do differently in production:**
[How you'd prevent this or handle it at scale]

---

## Example entry

### Issue: Compliance policy showed all devices as non-compliant

**What happened:**
After deploying the Windows compliance policy, every enrolled device showed "Not compliant" even though BitLocker was enabled and Defender was running.

**Root cause:**
The minimum OS version was set to `10.0.22631` (Windows 11 23H2), but the Parallels VM was running `10.0.22621` (Windows 11 22H2). The version check is an exact comparison, not a "family" check.

**How I diagnosed it:**
1. Checked Intune > Devices > [Device] > Device compliance — saw "OS version" as the failing check
2. Ran `winver` on the VM to get the exact build number
3. Compared against the policy setting

**Resolution:**
Updated the minimum OS version in the compliance policy to `10.0.22000` to accept any Windows 11 build, then ran Windows Update on the VM to get to 23H2 anyway.

**What I'd do differently in production:**
Set the minimum OS version to the oldest *supported* build rather than the latest. Use Windows Update rings to push devices toward the current version over time rather than blocking access immediately.

---

*Add your own entries below as you work through the project.*
