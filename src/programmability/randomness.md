# Randomness

<!--

- Every consensus commit a new random value is generated.
- Beginning of an epoch, validators create a global random value.
- One value is used to derive unique random value per transaction.
- Pseudo-random generator from a seed that is created once per epoch.

Qs:

- How does it work with consensus / parallel execution / fast path? works like a Clock
- Does it lose its unpredictability closer to the end of the epoch. no
- What is the UID of the Random object? 0x8
- 0x8 - Random - 8 is a lucky number
- Do we protect &mut access to 0x8

---

- RandomInner is updated.
- Every consensus commit the value inside is updated

---

- Developers call `new_generator` and pass in the global random object.
- ...which creates the RandomGenerator from the global seed with a fresh object ID.
- The RandomGenerator uses unknown unpredictable random bytes + fresh object UID from a transaction.

- then they use `generate_bytes` or `generate_u64` or any other integer. Or a value in a range.
- random shuffle of a vector.

Notes: pretty dope utility!

---

- 8 ball is a random number generator.


Difficulties:

- If you know the seed, then you can predict the random number.
- Random should not be used in a public function - predictable.
- Random failure is more expensive than a success scenario.
    - one way out is to first calculate randomness and then do a separate expensive operation.
    - they can set a limit to gas for failure scenarios, so the failure never happens.
    -

> `public entry` -> `entry` call
> there is a PTB attack on the Random object.

 -->
