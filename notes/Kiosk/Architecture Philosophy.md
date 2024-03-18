While implementing Kiosk we followed these principles:

1. While being a shared object (hence a shared state - accessible by anyone), Kiosk is an extension to the *true ownership* - once created, Kiosk can only be used by its owner; all sensitive operations such as "take", "list", "borrow" (and a mutable borrow) as well as "place" can only be performed by the Kiosk Owner. The only operation that a third party can perform is "purchase" an active listing created by the Owner.
   
2. Given the position - being the base for commercial applications on Sui - every change in the Kiosk must go through multiple rounds of testing / evaluation. The result has to answer the following questions: TBD
   
3. Permissioned extendability - while the base implementation aims to be as generic as possible (with some tradeoffs such as using SUI as the currency by default), any third party extensions or modifications should not conflict with the base principle of safety of assets (1). Transferring or entrusting ownership of the Kiosk would mean compromising security of the stored assets and, if happens, should be stated explicitly (either in the Wallet application or in a dapp). Extensions implemented via the Kiosk Extensions API can only installed by an explicit entry call "add_extension" so that hiding this call in an arbitraty code is impossible. 
   
4. TBD...