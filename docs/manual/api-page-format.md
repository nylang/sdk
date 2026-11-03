# API contract page format

Each member page answers these questions in this order:

1. **Identity and availability:** package, canonical owner/member, member kind,
   import entry, reference SDK/profile, and mode/platform requirements. Preserve
   generic receiver and getter/setter/operator identity; list re-exports separately.
2. **Exact declaration:** source spelling, parameters/passing modes, defaults,
   generic constraints and result. Do not manufacture source from incomplete face metadata.
3. **Purpose:** the concrete task and when to choose another operation.
4. **Inputs and state:** valid ranges/units/encoding, mutation and preconditions.
5. **Result and errors:** success payload, optional/Result/bool/sentinel meaning,
   pending/cancellation behavior, and panic/abort/unsafe conditions where applicable.
6. **Ownership and lifetime:** copies versus borrows/moves, allocation domain,
   returned-view lifetime/invalidation, cleanup owner and retained-callback lifetime.
7. **Cost and execution:** complexity, allocation/blocking, thread affinity,
   synchronization, executor/provider/target requirements. Say when unspecified.
8. **Examples:** complete minimal use and a meaningful boundary/failure case,
   expected behavior and a downloadable source. A fragment must be labelled.
9. **Related operations:** alternatives, matching error type, tutorial and release
   availability. Keep migration notes explicit without rewriting older versions.

Comments in shipped faces remain the immediate API contract source. A useful
manual explains implications, not just repeats the declaration. A category index
or search listing does not imply that a complete member page exists.
