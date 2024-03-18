
...

---

When designing the SuiFrens architecture we wanted to achieve two things:
1. We don't know what business will do / want to do in the future; and we want to "build to last". 
2. We can't afford a shared state - doing so would lead to extreme amount of centralization (especially around mints) and make transactions slower and more expensive

---

If we can't have a shared state, but we already know that we want to "mint" and "mix" (two completely different logics) and eventually want to have more applications; - how do we approach it then?

---

Let's identify the main feature of the application. Minting does "mint", mixing (ex breeding) also does "mint". And if we recap Winter Holidays (great times...), what they had was also "mint", just different logic around it.

(show function signatures)

```
fun mint(...): Capy {} 
fun mix(Capy, Capy): Capy {}
fun open_box(): Capy {} // !!!
```

---

**First conclusion**: we know the main feature of the application - minting new "frens".

---

#### Requirements: Mint

Now let's look at business requirements (user scenarios) from the start:
1. I go to SuiFrens website
2. I pay to mint a new SuiFren | (where does the Coin go?)
3. In each Cohort which is defined by the admin, only X SFs can be minted | (where do we enforce it?)

---

#### Requirements: Mix

1. I have two SuiFrens, I can mix them
2. Where does the Coin go this time? ;)
3. Each SuiFren can be minted only once in X time | (where do we store it?)
4. The mixing limit and the mixing cooldown should be configurable by admin | (where?)

---

#### Some Imaginary App?

1. SuiFren can turn into a new one - like phoenix - reborn from ashes
2. 



