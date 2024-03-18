Recently we created / reworked two big applications: Suifrens and SuiNS. Both applications are at their early stages, both will develop and grow. And what is especially important - we don't know how they will grow and which features they will have in a year or even 6 months. And that has put us into a situation where we need to create an application architecture in which decisions made today won't make us regret in the future.

In this document we describe practices we discovered while working on these applications, two main architecture approaches to designing modular and extendable Move packages and how to work with the constantly changing business requirements.

## Cut to the chase
Every application has a very generic and a basic feature it implements. For example, an NFT collection has a "mint" function which creates new NFTs; a liquidity pool has multiple basic functions: swap, add liquidity, remove liquidity; an auction has a start, an end and a bid functions; a marketplace or a trading application in general has list and purchase functions (or their variations based on the specifics).

Understanding the main feature of the application is extremely crucial when creating the architecture. Most of the product requirements specify tiny details of authorization, necessary actions, user base, interfaces. However, from the base architecture perspective it is a noise, a distraction. An imporant distraction, but we'll get there.

## Know the direction
After the root has been identified, next step would be understanding the direction in which the application is going. 


## Product details are not that important

## Guards for the root

## Authorization







